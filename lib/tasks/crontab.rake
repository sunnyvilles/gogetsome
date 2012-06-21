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
              product = Product.new(:url => product_url, :site_id => myntra_info.id, :country_id => myntra_info.country_id)
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
              product.save

							cat_key_words = doc.xpath('//meta[@name="keywords"]/@content').map(&:value)[0].to_s.split(",")
							indexed_categories = Category.where(:name => cat_key_words).index_by(&:name)
							existing_category_ids = []
							cat_key_words.each do |cat_key_word|
								category = indexed_categories[cat_key_word]
								if category.nil?
									category = Category.create(:name => cat_key_word, :associated_products_count => 1)
								else
									existing_category_ids << category.id
								end

								ProductCategory.create(:product_id => product.id, :category_id => category.id)
							end

							Category.update_all("associated_products_count = associated_products_count + 1", ["id IN (?)", existing_category_ids])

            rescue Exception => e
              puts "----Exception In Jabong crawling Internal loop----#{e.inspect}-------Backtrace---#{e.backtrace}"
            end
          end
          break if urls.length > 100
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
    begin
      try_count += 1
      Anemone.crawl("http://www.jabong.com/") do |anemone|
        anemone.on_every_page do |page|
          product_url = page.url.to_s
          if /[0-9]{1,10}+\.html/.match(product_url)
            urls << product_url
            doc = page.doc

            begin
              product = Product.new(:url => product_url, :site_id => jabong_info.id, :country_id => jabong_info.country_id)
              # Product name
              doc.css("span[property='gr:name']").each do |name|
                  puts "----ul------#{name.inner_html}"
                product.name = name.inner_html
              end

              # Product Image URL
              doc.css('img#prdImage').each do |img|
                puts "----ul------#{img['src']}"
                product.primary_image_url = img['src']
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

              # Actual Product Brand
              doc.css("span[property='gr:hasCurrencyValue']").each do |price|
                puts "----ul------#{price.inner_html}"
                product.actual_price = price.inner_html
              end
              product.status = 1
              product.save

							cat_key_words = doc.xpath('//meta[@name="keywords"]/@content').map(&:value)[0].to_s.split(",")
							indexed_categories = Category.where(:name => cat_key_words).index_by(&:name)
							existing_category_ids = []
							cat_key_words.each do |cat_key_word|
								category = indexed_categories[cat_key_word]
								if category.nil?
									category = Category.create(:name => cat_key_word, :associated_products_count => 1)
								else
									existing_category_ids << category.id
								end

								ProductCategory.create(:product_id => product.id, :category_id => category.id)
							end

							Category.update_all("associated_products_count = associated_products_count + 1", ["id IN (?)", existing_category_ids])

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