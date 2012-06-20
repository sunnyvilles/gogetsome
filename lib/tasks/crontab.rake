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
    urls = []
    Anemone.crawl("http://www.myntra.com/") do |anemone|
      anemone.on_every_page do |page|
        product_url = page.url.to_s
        if /[0-9]{1,10}+\/buy/.match(product_url)
          urls << product_url
          doc = page.doc
          
          begin
            product = Product.new(:url => product_url, :site_id => myntra_info.id, :country_id => myntra_info.country_id)
            # Product name
            doc.css('h1.product-title').each do |name|
              puts "----ul------#{name.inner_html}"
              product.name = name.inner_html
            end

            # Product Image URL
            doc.css('img#finalimage').each do |img|
              puts "----ul------#{img['src']}"
              product.primary_image_url = img['src']
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
            doc.css('div.pdp-sploff b').each do |aprice|
              puts "----ul------#{aprice.inner_html.gsub("%","")}"
              product.actual_price = aprice.inner_html.gsub("%","")
            end
            product.status = 1
            product.save



          rescue Exception => e
            puts "----E----#{e.inspect}"
          end
        end
        break if urls.length > 100
        puts "Now checking: " + product_url
        puts "Successfully checked"
      end
    end

    puts urls.inspect
  end

  desc "Mathrails: Test -> rake RAILS_ENV=development crontab:crawl_myntra_products_urls_for_complete_info
        crontab: 15 3 * * * cd /mnt/graboard/current && rake RAILS_ENV=development crontab:crawl_myntra_products_urls_for_complete_info"
  task :crawl_myntra_products_urls_for_complete_info => :environment do

    puts "----Started the cron for getting complete info of each product in myntra"
    Product.where(:status => 0, :site_id => Site.where(:name => "myntra").first.id).each do |product|
      require 'nokogiri'
      require 'open-uri'
      doc = nil
      doc = Nokogiri::HTML(open(product.url))

      # Product name
      doc.css('h1.product-title').each do |name|
        puts "----ul------#{name.inner_html}"
        product.name = name.inner_html
      end

      # Product Image URL
      doc.css('img#finalimage').each do |img|
        puts "----ul------#{img['src']}"
        product.primary_image_url = img['src']
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
      doc.css('div.pdp-sploff b').each do |aprice|
        puts "----ul------#{aprice.inner_html.gsub("%","")}"
        product.actual_price = aprice.inner_html.gsub("%","")
      end
      product.status = 1
      product.save
    end
  end

  desc "Mathrails: Test -> rake RAILS_ENV=development crontab:crawl_jabong_for_products
        crontab: 15 3 * * * cd /mnt/graboard/current && rake RAILS_ENV=development crontab:crawl_jabong_for_products"
  task :crawl_jabong_for_products => :environment do

    puts "----Started the cron for crawling jabong products"
    require 'anemone'
    jabong_info = Site.where(:name => "jabong").first
    urls = []
    Anemone.crawl("http://www.jabong.com/") do |anemone|
      anemone.on_every_page do |page|
        product_url = page.url.to_s
        if /[0-9]{1,10}+\.html/.match(product_url)
          urls << product_url
          begin
            Product.create(:url => product_url, :site_id => jabong_info.id, :country_id => jabong_info.country_id)
          rescue Exception => e
            puts "----E----#{e.inspect}"
          end
        end
        break if urls.length > 100
        puts "Now checking: " + product_url
        puts "Successfully checked"
      end
    end

    puts urls.inspect
  end

  desc "Mathrails: Test -> rake RAILS_ENV=development crontab:crawl_myntra_products_urls_for_complete_info
        crontab: 15 3 * * * cd /mnt/graboard/current && rake RAILS_ENV=development crontab:crawl_myntra_products_urls_for_complete_info"
  task :crawl_myntra_products_urls_for_complete_info => :environment do

    puts "----Started the cron for getting complete info of each product in myntra"
    Product.where(:status => 0, :site_id => Site.where(:name => "myntra").first.id).each do |product|
      require 'nokogiri'
      require 'open-uri'
      doc = nil
      doc = Nokogiri::HTML(open(product.url))

      # Product name
      doc.css('span.prd-title').each do |name|
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

      # Product Brand
      doc.css('span.prd-brand').each do |title|
        puts "----ul------#{title['title']}"
        product.brand = title['title']
      end

      # Discount Price
      doc.css('span.dprice').each do |dprice|
        puts "----ul------#{dprice.inner_html.split("</span>")[1].gsub(",","").strip.to_i}"
        product.discount_price = dprice.inner_html.split("</span>")[1].gsub(",","").strip.to_i
      end

      # Actual Product Brand
      doc.css('div.pd_prd_price_text_simple').each do |aprice|
        puts "----ul------#{aprice.inner_html.gsub("%","")}"
        product.actual_price = aprice.inner_html.gsub("Rs.","")
      end
      product.status = 1
      product.save
    end
  end
end