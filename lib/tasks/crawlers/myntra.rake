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

  desc "Mathrails: Test -> rake RAILS_ENV=development crontab:crawl_myntra_for_products
        crontab: 15 3 * * * cd /mnt/graboard/current && rake RAILS_ENV=development crontab:crawl_myntra_for_products >> "
  task :crawl_myntra_for_products => :environment do

    puts "----Started the cron for crawling myntra products"
    require 'anemone'
    myntra_info = Site.where(:name => "myntra").first
    urls, try_count = [], 0
    begin
      try_count += 1
      Anemone.crawl("http://www.myntra.com/") do |anemone|
        anemone.on_every_page do |page|
          product_url = page.url.to_s
          if /[0-9]{1,10}+\/buy/.match(product_url)
            urls << product_url
            doc = page.doc

            begin
              associate_categories = false

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
                product.status = 1
              rescue Exception => e
                puts "------Exception in  Yebhi Inner loop-----#{e.inspect}"
              end


              product.save

							if associate_categories
                ProductCategory.create_update_product_categories(:product_id => product.id,
                                                                 :categories => doc.xpath('//meta[@name="keyword"]/@content').map(&:value)[0].to_s.split(","))
              end

            rescue Exception => e
              puts "----Exception In Jabong crawling Internal loop----#{e.inspect}-------Backtrace---#{e.backtrace}"
            end
          end
          break if urls.length > 100000
          puts "Now checking: " + product_url
          puts "Successfully checked"
        end
      end
    rescue Exception => e
      retry if try_count < 5
      puts"-----------Exception in Myntra crwaling-----#{e.inspect}----Beacktrace--#{e.backtrace}"
    end

    puts urls.inspect
  end

end