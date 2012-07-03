namespace :myntra do

  desc "Mathrails: Test -> rake RAILS_ENV=development crontab:test"
  task :test => :environment do
    puts "text crontab #{Rails.env}"
  end

  desc "Mathrails: Test arguments -> rake RAILS_ENV=development crontab:test_arguments my_vars=1"
  task :test_arguments => :environment do
    puts "text crontab #{Rails.env} -- #{ENV["my_vars"]}"
  end

  desc "Mathrails: Test arguments -> rake RAILS_ENV=development crontab:test_call_other_rake_task my_vars=1"
  task :test_call_other_rake_task => :environment do
    puts "Calling crontab:test_arguments"
    Rake::Task['crontab:test_arguments'].invoke
  end

  desc "Mathrails: Test -> rake RAILS_ENV=development myntra:crawl_myntra_for_products
        crontab: 15 3 * * * cd /mnt/graboard/current && rake RAILS_ENV=development myntra:crawl_myntra_for_products file_name='/Users/madhu/Desktop/' >> "
  task :crawl_myntra_for_products => :environment do

    puts "----Started the cron for crawling myntra products"
    require 'anemone'
    myntra_info = Site.where(:name => "myntra").first
    start_index = 0
    Nokogiri::HTML(open(ENV["file_name"])).css("div#mk-search-results ul li a").each do |link|
      next unless /[0-9]{1,10}+\/buy/.match(link["href"])
      start_index += 1
      product_url = link["href"]
      puts "----product_url------#{product_url}"
      doc = Nokogiri::HTML(open(product_url))

      product = Product.where(:url => product_url).first
      if product.nil?
        associate_categories = true
        product = Product.create(:url => product_url, :site_id => myntra_info.id, :country_id => myntra_info.country_id)
      end

      begin
        # Product name
        doc.css("div.mk-zoom-hide h1").each do |name|
            puts "----Product name------#{name.inner_html}"
          product.name = name.inner_html
        end
        if product.name.present?

          # Product Image URL
          doc.css("div.mk-product-large-image a img").each do |img|
            puts "----Product Image URL------#{img['src']}------#{img['width']}-----#{img['height']}"
            product.primary_image_url = img['src']
            product.primary_image_width = img['width']
            product.primary_image_height = img['height']
          end

          # Product Brand
          doc.css("li.mk-brand-logo a").each do |brand|
            puts "----Product Brand------#{brand['title']}"
            product.brand = brand['title']
          end

          # Discount Price
          doc.css("div.mk-zoom-hide h3").each do |price|
            puts "----Actual Product Price------#{price.inner_html.split("Rs.")[1].gsub("\t","").split("<span")[0].strip.gsub(",","").to_i}"
            product.discount_price = price.inner_html.split("Rs.")[1].gsub("\t","").split("<span")[0].strip.gsub(",","").to_i
          end

          # Actual Product Price
          doc.css("span.strike").each do |price|
            puts "----Discount Price------#{price.inner_html}"
            product.actual_price = price.inner_html.gsub(",","").to_i
          end
        else
          doc.css('h1.product-title').each do |name|
              puts "----ul------#{name.inner_html}"
            product.name = name.inner_html
          end

          # Product Image URL
          doc.css('img#finalimage').each do |img|
            puts "----ul------#{img['src']}"
            product.primary_image_url = img['src']
            product.primary_image_width = img['width']
            product.primary_image_height = img['height']
          end

          # Product Brand
          doc.css('div.pdp-brand-logo a').each do |title|
            puts "----ul------#{title['title']}"
            product.brand = title['title']
          end

          # Discount Price
          doc.css('span.dprice').each do |dprice|
            puts "----ul------#{dprice.inner_html.split("</span>")[1].gsub(",","").strip.to_i}"
            product.discount_price = dprice.inner_html.split("</span>")[1].gsub(",","").strip.to_i
          end

          # Actual Product Brand
          doc.css("span.oprice").each do |aprice|
            puts "----ul------#{aprice.inner_html.gsub(",","")}"
            product.actual_price = aprice.inner_html.gsub(",","").to_i
          end
        end

        # Product Discount Percentage
        if product.actual_price.to_i > 0
          product.discount_percentage = ((product.actual_price.to_f-product.discount_price.to_f)*100.00/product.actual_price.to_f).round
        end

        product.status = 1 if product.name.present? && product.primary_image_url.present? && product.discount_price.present?
        puts "----start_index/GlobalConstant::PRODUCTS_PER_EACH_LEVEL------#{(start_index/GlobalConstant::PRODUCTS_PER_EACH_LEVEL)+1}"
        product.priority = (start_index/GlobalConstant::PRODUCTS_PER_EACH_LEVEL)+1

      rescue Exception => e
        puts "------Exception in  Myntra Inner loop-----#{e.inspect}"
      end

      product.save

      if associate_categories
        ProductCategory.create_update_product_categories(:product_id => product.id,
                                                         :categories => doc.xpath('//meta[@name="keyword"]/@content').map(&:value)[0].to_s.split(","),
                                                         :priority => product.priority)
      end
    end
  end

end