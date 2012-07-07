namespace :jabong do

  desc "Mathrails: Test -> rake RAILS_ENV=development jabong:crawl_jabong_products_urls_for_complete_info
        crontab: 15 3 * * * cd /mnt/graboard/current && rake RAILS_ENV=development jabong:crawl_jabong_products_urls_for_complete_info >> log/crawl_jabong_products_urls_for_complete_info.log"
  task :crawl_jabong_products_urls_for_complete_info => :environment do

    level_1_urls = ["http://www.jabong.com/shoes/",
                    "http://www.jabong.com/clothing/",
                    "http://www.jabong.com/sports/",
                    "http://www.jabong.com/bags/",
                    "http://www.jabong.com/jewellery/",
                    "http://www.jabong.com/accessories/",
                    "http://www.jabong.com/fragrances/",
                    "http://www.jabong.com/home-living/"
                   ]

    start_time, try_count = Time.now, 1
    puts "----Started the cron for getting complete info of each product in jabong----Start Time-------#{start_time}"

    begin
      require 'nokogiri'
      require 'open-uri'
      doc = nil
      jabong_info = Site.where(:name => "jabong").first
      level_1_urls.each do |level_1_url|
        puts "----level_1_url----#{level_1_url}"
        current_page, start_index = 1, 1
        while(true)
          current_page_product_count = 0
          top_level_url = level_1_url+"?page="+current_page.to_s
          puts "----top_level_url----#{top_level_url}"
          top_level_content = Nokogiri::HTML(open(top_level_url))
          top_level_content.css("ul#productsCatalog li a").each do |link|

            if /[0-9]{1,10}+\.html/.match(link["href"])
              doc = nil
              current_page_product_count += 1
              start_index += 1
              product_url = link["href"]
              puts "----started -----#{product_url}"
              doc = Nokogiri::HTML(open("http://www.jabong.com"+product_url)) rescue nil
              next if doc.nil?
              associate_categories = false

              product = Product.where(:url => product_url).first
              if product.nil?
                associate_categories = true
                product = Product.new(:url => product_url, :site_id => jabong_info.id, :country_id => jabong_info.country_id)
              end

              begin
                # Product name
                doc.css("span[property='gr:name']").each do |name|
                    puts "----ul------#{name.inner_html}"
                  product.name = name.inner_html
                end

                # Product Primary Image URL
                doc.css('img#prdImage').each do |img|
                  puts "----ul------#{img['src']}"
                  product.primary_image_url = img['src']
                  product.primary_image_width = img['width']
                  product.primary_image_height = img['height']
                end

                # Product Secondary Images
                doc.css("ul#productMoreImagesList li a img")[0..2].each_with_index do |img, index|
                  product["image_url_#{index+1}"] = img['src']
                end

                # Product Brand
                doc.css("span[property='gr:BusinessEntity']").each do |brand|
                  puts "----ul------#{brand.inner_html}"
                  product.brand = brand.inner_html
                end

                # Product Discount Price
                doc.css("span[property='gr:hasCurrencyValue']").each do |price|
                  puts "----ul------#{price.inner_html}"
                  product.discount_price = price.inner_html
                end

                # TODO :: Need to populate the actual price. Temporarily I have placed the actual price as Discount Price
                # Product Actual Price
                doc.css("div.pd_prd_price_text_simple.old").each do |price|
                  puts "-------aprice-----#{price}"
                  puts "----ul------#{price.inner_html.split("Rs.")[1].to_s.strip.gsub(",","").to_i}"
                  product.actual_price = price.inner_html
                end

                # Product Discount Percentage
                if product.actual_price.to_i > 0
                  product.discount_percentage = ((product.actual_price.to_f-product.discount_price.to_f)*100.00/product.actual_price.to_f).round
                end

                product.status = 1 if product.name.present? && product.primary_image_url.present? && product.discount_price.present?
                puts "----start_index/GlobalConstant::PRODUCTS_PER_EACH_LEVEL------#{(start_index/GlobalConstant::PRODUCTS_PER_EACH_LEVEL)+1}"
                product.priority = (start_index/GlobalConstant::PRODUCTS_PER_EACH_LEVEL)+1

              rescue Exception => e
                puts "------Exception in  jabong Inner loop-----#{e.inspect}"
              end

              product.save

              if associate_categories
                categories = []
                doc.css("li.prs a").each do |breadcrum|
                  categories << breadcrum.inner_html if breadcrum.inner_html != "Home"
                end
                ProductCategory.create_update_product_categories(:product_id => product.id,
                                                                 :categories => categories,
                                                                 :priority => product.priority,
                                                                 :discount_price => product.discount_price,
                                                                 :discount_percentage => product.discount_percentage
                                                               )
              end
            end
          end
          if current_page_product_count < 3
            current_page_product_count = 0
            puts "------came into break"
            break
          end
          current_page += 1
        end
      end
      try_count += 1
    rescue Exception => e
      puts "----Exception in jabong Outer loop -----#{e.inspect}-----#{e.backtrace}"
      try_count += 1
      retry if try_count < 4
    end

    puts "----Ended the cron for Jabong crawl --- End Time #{Time.now}"
  end
end