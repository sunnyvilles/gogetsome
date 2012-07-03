namespace :zovi do

  desc "Mathrails: Test -> rake RAILS_ENV=development zovi:crawl_zovi_products_urls_for_complete_info
        crontab: 15 3 * * * cd /mnt/graboard/current && rake RAILS_ENV=development zovi:crawl_zovi_products_urls_for_complete_info >> log/crawl_zovi_products_urls_for_complete_info.log"
  task :crawl_jabong_products_urls_for_complete_info => :environment do

    level_1_urls_hash = [{:url => "http://zovi.com/womens-knit-tops", :categories => ["women", "tops", "knits"]},
                    {:url => "http://zovi.com/womens-blouses-and-shirts", :categories => ["women", "blouses", "shirts"]},
                    {:url => "http://zovi.com/womens-casual-dresses", :categories => ["women", "casual dresses"]},
                    {:url => "http://zovi.com/womens-trousers", :categories => ["women", "trousers"]},
                    {:url => "http://zovi.com/womens-sportswear-pants", :categories => ["women", "sportswear", "sportswear pants"]},
                    {:url => "http://zovi.com/womens-jeans", :categories => ["women", "jeans"]},
                    {:url => "http://zovi.com/womens-shorts", :categories => ["women", "shorts"]},
                    {:url => "http://zovi.com/womens-wallets", :categories => ["women", "wallets"]},
                    {:url => "http://zovi.com/womens-clutches", :categories => ["women","clutches"]},
                    {:url => "http://zovi.com/womens-handbags", :categories => ["women", "handbags"]},
                    {:url => "http://zovi.com/womens-belts", :categories => ["women", "belts"]},
                    {:url => "http://zovi.com/womens-fashion-jewellery", :categories => ["women", "jewellery"]},
                    {:url => "http://zovi.com/womens-scarves", :categories => ["women", "scarves"]},
                    {:url => "http://zovi.com/womens-sandals-and-flats", :categories => ["women", "sandals", "sandals and flats"]},
                    {:url => "http://zovi.com/womens-heels", :categories => ["women", "heels"]},
                    {:url => "http://zovi.com/womens-ballerinas", :categories => ["women", "ballerinas"]},
                    {:url => "http://zovi.com/womens-flipflops", :categories => ["women", "flipflops"]},
                    {:url => "http://zovi.com/womens-socks", :categories => ["women", "socks"]},
                    {:url => "http://zovi.com/mens-formal-shirts", :categories => ["men", "formal shirts"]},
                    {:url => "http://zovi.com/mens-casual-shirts", :categories => ["men", "casual shirts"]},
                    {:url => "http://zovi.com/mens-eveningwear-shirts", :categories => ["men", "eveningwear shirts"]},
                    {:url => "http://zovi.com/mens-round-necks", :categories => ["men", "round necks"]},
                    {:url => "http://zovi.com/mens-polos", :categories => ["men", "polos"]},
                    {:url => "http://zovi.com/mens-denims", :categories => ["men", "denim"]},
                    {:url => "http://zovi.com/mens-formal-trousers", :categories => ["men", "formal trousers"]},
                    {:url => "http://zovi.com/mens-casual-trousers", :categories => ["men", "casual trousers"]},
                    {:url => "http://zovi.com/mens-shorts", :categories => ["men", "shorts"]},
                    {:url => "http://zovi.com/mens-formal-shoes", :categories => ["men", "formal shoes"]},
                    {:url => "http://zovi.com/mens-casual-shoes", :categories => ["men", "casual shoes"]},
                    {:url => "http://zovi.com/mens-leather-slippers", :categories => ["men", "leather slippers"]},
                    {:url => "http://zovi.com/mens-flipflops", :categories => ["men", "flipflops"]},
                    {:url => "http://zovi.com/mens-socks", :categories => ["men", "socks"]},
                    {:url => "http://zovi.com/mens-belts", :categories => ["men", "belts"]},
                    {:url => "http://zovi.com/mens-wallets", :categories => ["men", "wallets"]},
                    {:url => "http://zovi.com/mens-ties", :categories => ["men", "ties"]},
                    {:url => "http://zovi.com/mens-bags", :categories => ["men", "bags"]},
                    {:url => "http://zovi.com/mens-sportswear-tees", :categories => ["men", "sportswear", "sportswear tees"]},
                    {:url => "http://zovi.com/mens-sportswear-jackets", :categories => ["men", "sportswear", "sportswear jackets"]},
                    {:url => "http://zovi.com/mens-sportswear-pants", :categories => ["men", "sportswear", "sportswear pants"]},
                    {:url => "http://zovi.com/mens-swimwear", :categories => ["men", "swimwear"]}
                   ]

    start_time, try_count = Time.now, 1
    puts "----Started the cron for getting complete info of each product in zovi----Start Time-------#{start_time}"

    begin
      require 'nokogiri'
      require 'open-uri'
      doc = nil
      jabong_info = Site.where(:name => "zovi").first
      level_1_urls_hash.each do |level_1_url, categories|
        puts "----level_1_url----#{level_1_url}"
        start_index = 1
        top_level_content = Nokogiri::HTML(open(level_1_url))
        top_level_content.css("a.sku-detail-link").each do |link|

            doc = nil
            start_index += 1
            product_url = link["href"]
            puts "----started -----#{product_url}"
            doc = Nokogiri::HTML(open("http://www.jabong.com"+product_url)) rescue nil
            next if doc.nil?
            associate_categories = false

            product = Product.where(:url => product_url).first
            if product.nil?
              associate_categories = true
              product = Product.create(:url => product_url, :site_id => jabong_info.id, :country_id => jabong_info.country_id)
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
              doc.css("ul#productMoreImagesList li a img").each_with_index do |img, index|
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
                categories << breadcrum.inner_html if breadcrum != "Home"
              end
              ProductCategory.create_update_product_categories(:product_id => product.id,
                                                               :categories => categories,
                                                               :priority => product.priority)
            end
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