namespace :yebhi do

  desc "Mathrails: Test -> rake RAILS_ENV=development yebhi:crawl_yebhi_products_urls_for_complete_info
        crontab: 15 3 * * * cd /mnt/graboard/current && rake RAILS_ENV=development yebhi:crawl_yebhi_products_urls_for_complete_info >> log/crawl_yebhi_products_urls_for_complete_info.log"
  task :crawl_yebhi_products_urls_for_complete_info => :environment do

    level_1_urls = ["http://www.yebhi.com/online-shopping/footwear.html?source=top2",
                      "http://www.yebhi.com/online-shopping/apparels.html?source=top2",
                      "http://www.yebhi.com/online-shopping/lingerie.html?source=top1",
                      "http://www.yebhi.com/online-shopping/lifestyle.html?source=top",
                      "http://www.yebhi.com/online-shopping/jewellery-and-watches.html?source=top1",
                      "http://www.yebhi.com/online-shopping/mobiles.html?source=top1",
                      "http://www.yebhi.com/online-shopping/electronics.html?source=top1",
                      "http://www.yebhi.com/online-shopping/home-and-kitchen.html?source=top"
                     ]
    start_time, try_count = Time.now, 1
    puts "----Started the cron for getting complete info of each product in jabong----Start Time-------#{start_time}"

    begin
      require 'nokogiri'
      require 'open-uri'
      doc = nil
      yebhi_info = Site.where(:name => "yebhi").first
      level_1_urls.each do |level_1_url|
        puts "----level_1_url----#{level_1_url}"
        start_index = 1
        while(true)
          current_page_product_count = 0
          top_level_url = level_1_url+"&startIndex="+start_index.to_s
          puts "----top_level_url----#{top_level_url}"
          top_level_content = Nokogiri::HTML(open(top_level_url))
          level_1_product_urls = []
          top_level_content.css("a.gotopage").each do |link|

            if /[0-9]{1,10}+\/PD/.match(link["href"])
              if level_1_product_urls.include?(link["href"])
                next
              else
                level_1_product_urls << link["href"]
              end
              
              doc = nil
              current_page_product_count += 1

              puts "-----incremented the current_page_product_count #{start_index}"
              product_url = link["href"]
              puts "----started -----#{"http://www.yebhi.com"+product_url}"
              doc = Nokogiri::HTML(open("http://www.yebhi.com"+product_url)) rescue nil
              next if doc.nil?
              start_index += 1
              associate_categories = false

              product = Product.where(:url => product_url).first
              if product.nil?
                associate_categories = true
                product = Product.create(:url => product_url, :site_id => yebhi_info.id, :country_id => yebhi_info.country_id)
              end

              begin
                # Product name
                doc.css("div.product-desc").each do |name|
                  puts "----ul------#{name.inner_html}"
                  product.name = name.inner_html
                end

                # Product Image URL
                doc.css("img.product-page-pimage").each do |img|
                  puts "----ul------#{img['src']}"
                  product.primary_image_url = img['src']
                end

                # Product Secondary Images
                doc.css("div.product-thumbnail a img")[0..2].each_with_index do |img, index|
                  product["image_url_#{index+1}"] = img['src']
                end

                # Product Brand
                product.brand = product.name.split(" ")[0]

                # Discount Price
                doc.css("span.price-offer").each do |dprice|
                  puts dprice.inner_html.split("INR")[1].strip
                  product.discount_price = dprice.inner_html.split("INR")[1].strip
                end

                # Actual Product Price
                doc.css("span.price-normal").each do |aprice|
                  puts aprice.inner_html.split("INR")[1].split("</str")[0]
                  product.actual_price = aprice.inner_html.split("INR")[1].split("</str")[0]
                end

                # Product Discount Percentage
                if product.actual_price.to_i > 0
                  product.discount_percentage = ((product.actual_price.to_f-product.discount_price.to_f)*100.00/product.actual_price.to_f).round
                end
                
                product.status = 1 if product.name.present? && product.primary_image_url.present? && product.discount_price.present?
                puts "----start_index/GlobalConstant::PRODUCTS_PER_EACH_LEVEL------#{(start_index/GlobalConstant::PRODUCTS_PER_EACH_LEVEL)+1}"
                product.priority = (start_index/GlobalConstant::PRODUCTS_PER_EACH_LEVEL)+1

              rescue Exception => e
                puts "------Exception in  Yebhi Inner loop-----#{e.inspect}"
              end

              product.save

              if associate_categories
                categories = []
                begin
                  product_brand_cats = doc.css("div.product-code")[0].inner_html.split("Product Code:")
                  product.brand = product_brand_cats[0].strip
                  partail_product_code = product_brand_cats[1].split("-")[0].strip
                  product_name = product.name.gsub(product.brand, "").split(partail_product_code)[0].strip
                  product_name.split(" ").each do |category|
                    categories << category
                  end
                rescue Exception => e
                  puts "----Exception in calculating the categories---#{e.inspect}"
                end
                ProductCategory.create_update_product_categories(:product_id => product.id,
                                                                 :categories => categories)
              end
            end
          end
          if current_page_product_count < 6
            current_page_product_count = 0
            puts "------came into break"
            break
          end
        end
      end
    rescue Exception => e
      puts "----Exception in Yebhi Outer loop -----#{e.inspect}-----#{e.backtrace}"
      try_count += 1
      retry if try_count < 4
    end
    puts "----Ended the cron for Jabong crawl --- End Time #{Time.now}"
  end
end