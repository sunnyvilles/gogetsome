namespace :craftsvilla do

  desc "Mathrails: Test -> rake RAILS_ENV=development craftsvilla:crawl_craftsvilla_products_urls_for_complete_info
        crontab: 15 3 * * * cd /mnt/graboard/current && rake RAILS_ENV=development craftsvilla:crawl_craftsvilla_products_urls_for_complete_info >> log/crawl_craftsvilla_products_urls_for_complete_info.log"
  task :crawl_craftsvilla_products_urls_for_complete_info => :environment do

    level_1_urls = [{:url => "http://www.craftsvilla.com/jewellery-jewelry.html", :category => ["Jewellery"]},
                    {:url => "http://www.craftsvilla.com/sarees-sari.html", :category => ["Sarees"]},
                    {:url => "http://www.craftsvilla.com/bags.html", :category => ["Bags"]},
                    {:url => "http://www.craftsvilla.com/home-decor-products.html", :category => ["Home Decor"]},
                    {:url => "http://www.craftsvilla.com/clothing.html", :category => ["Clothing"]},
                    {:url => "http://www.craftsvilla.com/accessories.html", :category => ["Accessories"]},
                    {:url => "http://www.craftsvilla.com/home-furnishing.html", :category => ["Home Furnishing"]},
                    {:url => "http://www.craftsvilla.com/bath-beauty-1.html", :category => ["Bath & Beauty"]},
                    {:url => "http://www.craftsvilla.com/food-spices-herbs-tea-chocolates.html", :category => ["Food & Health"]},
                    {:url => "http://www.craftsvilla.com/gifts-birthday-anniversary-wedding.html", :category => ["Gifts"]},
                    {:url => "http://www.craftsvilla.com/kids-baby-names-toy.html", :category => ["Kids", "Baby", "Toys"]},
                    {:url => "http://www.craftsvilla.com/books-india.html", :category => ["Books"]},
                    {:url => "http://www.craftsvilla.com/footwear-1.html", :category => ["Footwaer"]},
                    {:url => "http://www.craftsvilla.com/new-arrivals-new-product-launches.html", :category => []},
                    {:url => "http://www.craftsvilla.com/marriage-n-love.html", :category => ["Wedding"]},
                    {:url => "http://www.craftsvilla.com/spiritual-books-pooja.html", :category => ["Spiritual"]},
                    {:url => "http://www.craftsvilla.com/supplies-1.html", :category => ["Supplies"]}
                   ]


    start_time, try_count = Time.now, 1
    puts "----Started the cron for getting complete info of each product in jabong----Start Time-------#{start_time}"
    
    begin
      require 'nokogiri'
      require 'open-uri'
      doc = nil
      craftsvilla_info = Site.where(:name => "craftsvilla").first
      level_1_urls.each do |level_1_url_hash|
        level_1_url = level_1_url_hash[:url]
        categories = level_1_url_hash[:category]

        puts "----level_1_url----#{level_1_url}"
        current_page, start_index = 1, 1
        while(true)
          current_page_product_count = 0
          top_level_url = level_1_url+"?p="+current_page.to_s
          puts "----top_level_url----#{top_level_url}"
          top_level_content = Nokogiri::HTML(open(top_level_url))
          top_level_content.css("div.category-products ul li div.prCnr a.product-image").each do |link|

            if /.html/.match(link["href"])
              doc = nil
              current_page_product_count += 1
              product_url = link["href"]
              puts "----started -----#{product_url}"
              doc = Nokogiri::HTML(open(product_url)) rescue nil
              next if doc.nil?
              associate_categories = false
              start_index += 1
              product = Product.where(:url => product_url).first
              if product.nil?
                associate_categories = true
                product = Product.create(:url => product_url, :site_id => craftsvilla_info.id, :country_id => craftsvilla_info.country_id)
              end

              begin
                # Product name
                doc.css("div.details h1").each do |name|
                  puts "----ul------#{name.inner_html}"
                  product.name = name.inner_html
                end

                # Product Image URL
                doc.css("a#cloudZoom img").each do |img|
                  puts "----ul------#{img['src']}"
                  product.primary_image_url = img['src']
                end

                # Product Secondary Images
                doc.css("div.product-img-more ul li a img")[0..2].each_with_index do |img, index|
                  product["image_url_#{index+1}"] = img['src']
                end

                # Product Brand
                doc.css("p.vendorName a").each do |brand|
                  product.brand = brand.inner_html
                end

                actual_price_array = doc.css("div#Price div span.regular-price")
                if actual_price_array.length > 0
                  doc.css("div#Price div span.regular-price").each do |dprice|
                    puts dprice.inner_html.split("Rs. ")[1].gsub(",","").to_i
                    product.discount_price = dprice.inner_html.split("Rs. ")[1].gsub(",","").to_i
                  end
                else
                  # Discount Price
                  puts doc.css("div.price-box p.special-price span.price")[0].inner_html.split("Rs. ")[1].gsub(",","").to_i
                  product.discount_price = doc.css("div.price-box p.special-price span.price")[0].inner_html.split("Rs. ")[1].gsub(",","").to_i

                  # Actual Product Price
                  puts doc.css("div.price-box p.old-price span.price")[0].inner_html.split("Rs. ")[1].gsub(",","").to_i
                  product.actual_price = doc.css("div.price-box p.old-price span.price")[0].inner_html.split("Rs. ")[1].gsub(",","").to_i
                end

                # Product Discount Percentage
                if product.actual_price.to_i > 0
                  product.discount_percentage = ((product.actual_price.to_f-product.discount_price.to_f)*100.00/product.actual_price.to_f).round
                end


                product.status = 1 if product.name.present? && product.primary_image_url.present? && product.discount_price.present?
                puts "----start_index/GlobalConstant::PRODUCTS_PER_EACH_LEVEL------#{(start_index/GlobalConstant::PRODUCTS_PER_EACH_LEVEL)+1}"
                product.priority = (start_index/GlobalConstant::PRODUCTS_PER_EACH_LEVEL)+1

              rescue Exception => e
                puts "------Exception in  craftsvilla Inner loop-----#{e.inspect}"
              end

              product.save

              if associate_categories
                ProductCategory.create_update_product_categories(:product_id => product.id,
                                                                 :categories => categories)
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
    rescue Exception => e
      puts "----Exception in craftsvilla Outer loop -----#{e.inspect}-----#{e.backtrace}"
      try_count += 1
      retry if try_count < 4
    end
    puts "----Ended the cron for Jabong crawl --- End Time #{Time.now}"
  end
end