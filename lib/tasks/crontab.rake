namespace :crontab do

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
        crontab: 15 3 * * * cd /mnt/graboard/current && rake RAILS_ENV=development crontab:crawl_myntra_for_products"
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

  desc "Mathrails: Test -> rake RAILS_ENV=development crontab:crawl_jabong_for_products
        crontab: 15 3 * * * cd /mnt/graboard/current && rake RAILS_ENV=development crontab:crawl_jabong_for_products"
  task :crawl_jabong_for_products => :environment do

    puts "----Started the cron for crawling jabong products"
    require 'anemone'
    jabong_info = Site.where(:name => "jabong").first
    urls, try_count = [], 0
    require 'redis'
    begin
      empty_docs = 0
      try_count += 1
      Anemone.crawl("http://www.jabong.com/") do |anemone|
        anemone.storage = Anemone::Storage.Redis
        anemone.on_every_page do |page|
          product_url = page.url.to_s
          if /[0-9]{1,10}+\.html/.match(product_url)
            urls << product_url
            doc = page.doc

            begin
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

                # Product Image URL
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

                # Discount Price
                doc.css("span[property='gr:hasCurrencyValue']").each do |price|
                  puts "----ul------#{price.inner_html}"
                  product.discount_price = price.inner_html
                end
                
                # TODO :: Need to populate the actual price. Temporarily I have placed the actual price as Discount Price
                # Actual Product Brand
                doc.css("span[property='gr:hasCurrencyValue']").each do |price|
                  puts "----ul------#{price.inner_html}"
                  product.actual_price = price.inner_html
                end
                product.status = 1
                
              rescue Exception => e
                puts "------Exception in  Yebhi Inner loop-----#{e.inspect}"
              end
              
              product.save

							if associate_categories
                ProductCategory.create_update_product_categories(:product_id => product.id,
                                                                 :categories => doc.xpath('//meta[@name="keywords"]/@content').map(&:value)[0].to_s.split(","))
              end

            rescue Exception => e
              puts "----Exception In Jabong crwaling Internal loop----#{e.inspect}-------Backtrace---#{e.backtrace}"
            end
          end
          break if urls.length > 100000
          puts "Now checking: " + product_url
          puts "Successfully checked"
        end
      end
    rescue Exception => e
      retry if try_count < 5
      puts"-----------Exception in Jabong crwaling-----#{e.inspect}----Beacktrace--#{e.backtrace}"
    end

    puts urls.inspect
  end

  desc "Mathrails: Test -> rake RAILS_ENV=development crontab:crawl_yebhi_products_urls_for_complete_info
        crontab: 15 3 * * * cd /mnt/graboard/current && rake RAILS_ENV=development crontab:crawl_yebhi_products_urls_for_complete_info"
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


    
    puts "----Started the cron for getting complete info of each product in Yebhi"
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
            start_index += 1
            
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

                # Actual Product Brand
                doc.css("span.price-normal").each do |aprice|
                  puts aprice.inner_html.split("INR")[1].split("</str")[0]
                  product.actual_price = aprice.inner_html.split("INR")[1].split("</str")[0]
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
            end
          end
          if current_page_product_count < 6
            current_page_product_count = 0
            puts "------came into break"
            break
          end
          # Temp condition to restrict the products
          if start_index > 300
            break
          end
        end
      end
    rescue Exception => e
      puts "----Exception in Yebhi Outer loop -----#{e.inspect}-----#{e.backtrace}"
    end
  end

  desc "Mathrails: Test -> rake RAILS_ENV=development crontab:crawl_craftsvilla_products_urls_for_complete_info
        crontab: 15 3 * * * cd /mnt/graboard/current && rake RAILS_ENV=development crontab:crawl_craftsvilla_products_urls_for_complete_info"
  task :crawl_craftsvilla_products_urls_for_complete_info => :environment do
    #"http://www.craftsvilla.com/jewellery-jewelry.html",
                      
    level_1_urls = ["http://www.craftsvilla.com/sarees-sari.html",
                      "http://www.craftsvilla.com/bags.html",
                      "http://www.craftsvilla.com/home-decor-products.html",
                      "http://www.craftsvilla.com/clothing.html",
                      "http://www.craftsvilla.com/accessories.html",
                      "http://www.craftsvilla.com/home-furnishing.html",
                      "http://www.craftsvilla.com/bath-beauty-1.html",
                      "http://www.craftsvilla.com/food-spices-herbs-tea-chocolates.html",
                      "http://www.craftsvilla.com/gifts-birthday-anniversary-wedding.html",
                      "http://www.craftsvilla.com/kids-baby-names-toy.html",
                      "http://www.craftsvilla.com/books-india.html",
                      "http://www.craftsvilla.com/footwear-1.html",
                      "http://www.craftsvilla.com/new-arrivals-new-product-launches.html",
                      "http://www.craftsvilla.com/marriage-n-love.html",
                      "http://www.craftsvilla.com/spiritual-books-pooja.html",
                      "http://www.craftsvilla.com/supplies-1.html"
                     ]


    puts "----Started the cron for getting complete info of each product in craftsvilla"
    begin
      require 'nokogiri'
      require 'open-uri'
      doc = nil
      craftsvilla_info = Site.where(:name => "craftsvilla").first
      level_1_urls.each do |level_1_url|
        puts "----level_1_url----#{level_1_url}"
        current_page = 1
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

                  # Actual Product Brand
                  puts doc.css("div.price-box p.old-price span.price")[0].inner_html.split("Rs. ")[1].gsub(",","").to_i
                  product.actual_price = doc.css("div.price-box p.old-price span.price")[0].inner_html.split("Rs. ")[1].gsub(",","").to_i
                end
                
                
                product.status = 1

              rescue Exception => e
                puts "------Exception in  craftsvilla Inner loop-----#{e.inspect}"
              end

              product.save

              if associate_categories
                ProductCategory.create_update_product_categories(:product_id => product.id,
                                                                 :categories => doc.xpath('//meta[@name="keywords"]/@content').map(&:value)[0].to_s.split(","))
              end
            end
          end
          if current_page_product_count < 3
            current_page_product_count = 0
            puts "------came into break"
            break
          end
          if current_page > 15
            break
          end
          current_page += 1
        end
      end
    rescue Exception => e
      puts "----Exception in craftsvilla Outer loop -----#{e.inspect}-----#{e.backtrace}"
    end
  end
  
#  desc "Mathrails: Test -> rake RAILS_ENV=development crontab:crawl_myntra_products_urls_for_complete_info
#        crontab: 15 3 * * * cd /mnt/graboard/current && rake RAILS_ENV=development crontab:crawl_myntra_products_urls_for_complete_info#"
#  task :crawl_myntra_products_urls_for_complete_info => :environment do
#
#    puts "----Started the cron for getting complete info of each product in myntra"
#    Product.where(:status => 0, :site_id => Site.where(:name => "myntra").first.id).each do |product|
#      require 'nokogiri'
#      require 'open-uri'
#      doc = nil
#      doc = Nokogiri::HTML(open("http://www.myntra.com/Sports-Shoes/Adidas/Adidas-Men-TRX-HG-Blue-Sports-Shoes/34849/buy"))
#
#      # Product name
#      doc.css('h1.product-title').each do |name|
#        puts "----ul------#{name.inner_html}"
#        product.name = name.inner_html
#      end
#
#      # Product Image URL
#      doc.css('img#finalimage').each do |img|
#        puts "----ul------#{img['src']}"
#        product.primary_image_url = img['src']
#      end
#
#      # Product Brand
#      doc.css('div.pdp-brand-logo a').each do |title|
#        puts "----ul------#{title['title']}"
#        product.brand = title['title']
#      end
#
#      # Discount Price
#      doc.css('span.dprice').each do |dprice|
#        puts "----ul------#{dprice.inner_html.split("</span>")[1].gsub(",","").strip.to_i}"
#        product.discount_price = dprice.inner_html.split("</span>")[1].gsub(",","").strip.to_i
#      end
#
#      # Actual Product Brand
#      doc.css('div.pdp-sploff b').each do |aprice|
#        puts "----ul------#{aprice.inner_html.gsub("%","")}"
#        product.actual_price = aprice.inner_html.gsub("%","")
#      end
#      product.status = 1
#      product.save
#    end
#  end

#  desc "Mathrails: Test -> rake RAILS_ENV=development crontab:crawl_jabong_for_products
#        crontab: 15 3 * * * cd /mnt/graboard/current && rake RAILS_ENV=development crontab:crawl_jabong_for_products#"
#  task :crawl_jabong_for_products => :environment do
#
#    puts "----Started the cron for crawling jabong products"
#    require 'anemone'
#    jabong_info = Site.where(:name => "jabong").first
#    urls = []
#    Anemone.crawl("http://www.jabong.com/") do |anemone|
#      anemone.on_every_page do |page|
#        product_url = page.url.to_s
#        if /[0-9]{1,10}+\.html/.match(product_url)
#          urls << product_url
#          begin
#
#            Product.new(:url => product_url, :site_id => jabong_info.id, :country_id => jabong_info.country_id)
#          rescue Exception => e
#            puts "----E----#{e.inspect}"
#          end
#        end
#        break if urls.length > 100
#        puts "Now checking: " + product_url
#        puts "Successfully checked"
#      end
#    end
#
#    puts urls.inspect
#  end

#  desc "Mathrails: Test -> rake RAILS_ENV=development crontab:crawl_myntra_products_urls_for_complete_info
#        crontab: 15 3 * * * cd /mnt/graboard/current && rake RAILS_ENV=development crontab:crawl_myntra_products_urls_for_complete_info#"
#  task :crawl_myntra_products_urls_for_complete_info => :environment do
#
#    puts "----Started the cron for getting complete info of each product in myntra"
#    Product.where(:status => 0, :site_id => Site.where(:name => "myntra").first.id).each do |product|
#      require 'nokogiri'
#      require 'open-uri'
#      doc = nil
#      doc = Nokogiri::HTML(open(product.url))
#
#      # Product name
#      doc.css('span.prd-title').each do |name|
#        puts "----ul------#{name.inner_html}"
#        product.name = name.inner_html
#      end
#
#      # Product Image URL
#      doc.css('img#prdImage').each do |img|
#        puts "----ul------#{img['src']}"
#        product.primary_image_url = img['src']
#        product.primary_image_width = img['width']
#        product.primary_image_height = img['height']
#      end
#
#      # Product Brand
#      doc.css('span.prd-brand').each do |title|
#        puts "----ul------#{title['title']}"
#        product.brand = title['title']
#      end
#
#      # Discount Price
#      doc.css('span.dprice').each do |dprice|
#        puts "----ul------#{dprice.inner_html.split("</span>")[1].gsub(",","").strip.to_i}"
#        product.discount_price = dprice.inner_html.split("</span>")[1].gsub(",","").strip.to_i
#      end
#
#      # Actual Product Brand
#      doc.css('div.pd_prd_price_text_simple').each do |aprice|
#        puts "----ul------#{aprice.inner_html.gsub("%","")}"
#        product.actual_price = aprice.inner_html.gsub("Rs.","")
#      end
#      product.status = 1
#      product.save
#    end
#  end
end