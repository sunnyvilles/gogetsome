namespace :firstcry do

  desc "Mathrails: Test -> rake RAILS_ENV=development firstcry:crawl_firstcry_products_urls_for_complete_info
        crontab: 15 3 * * * cd /mnt/graboard/current && rake RAILS_ENV=development firstcry:crawl_firstcry_products_urls_for_complete_info >> log/crawl_firstcry_products_urls_for_complete_info.log"
  task :crawl_firstcry_products_urls_for_complete_info => :environment do

    level_1_urls = ["http://www.firstcry.com/Diapering",
                    "http://www.firstcry.com/Feeding-and-Nursing",
                    "http://www.firstcry.com/Bath-Skin-and-Health-Care",
                    "http://www.firstcry.com/Toys",
                    "http://www.firstcry.com/Clothes-Shoes-and-Fashion",
                    "http://www.firstcry.com/Baby-Gear-and-Nursery",
                    "http://www.firstcry.com/Birthday-and-Gifts",
                    "http://www.firstcry.com/Back-To-School",
                    "http://www.firstcry.com/books-cds-games"
                   ]

    start_time, try_count = Time.now, 1
    puts "----Started the cron for getting complete info of each product in firstcry----Start Time-------#{start_time}"

    begin
      require 'nokogiri'
      require 'open-uri'
      doc = nil
      firstcry_info = Site.where(:name => "firstcry").first
      level_1_urls.each do |level_1_url|
        Nokogiri::HTML(open(level_1_url)).css("div.dpage_image a").each do |level_2_url|
          cat_id = level_2_url["href"].split("/")[level_2_url["href"].split("/").length-1]
          complete_level_2_url = level_2_url["href"]+"?#{cat_id}@,@,@,@,@,@@@@@1@2@5000"
          puts "----complete_level_2_url-----#{complete_level_2_url}"
          start_index = 0
          Nokogiri::HTML(open(complete_level_2_url)).css("ul.item_list li a").each do |link|
            product_url = link["href"]
            if /[0-9]{1,10}+\/product-detail/.match(product_url)
              
              puts "----started product link-----#{product_url}"
              doc = Nokogiri::HTML(open(product_url)) rescue nil
              next if doc.nil?
              associate_categories = false
              start_index += 1
              product = Product.where(:url => product_url).first
              if product.nil?
                associate_categories = true
                product = Product.new(:url => product_url, :site_id => firstcry_info.id, :country_id => firstcry_info.country_id)
              end

              begin
                # Product name
                product.name = doc.css("h1")[0].inner_html

                # Product Image URL
                product.primary_image_url = doc.css("a.jqzoom")[0]["href"]

                # Product Secondary Images
                doc.css("div.small_img_box img")[0..1].each_with_index do |img, index|
                  product["image_url_#{index+1}"] = img['src']
                end

                # Product Brand
                product.brand = product.name.split(" ")[0]

                # Discount Price
                product.discount_price = doc.css("span.lbl_mrp_css")[1].inner_html

                # Actual Product Price
                actual_price = doc.css("span.lbl_afdisco_css")[1]
                product.actual_price = actual_price.inner_html if actual_price.present?

                # Product Discount Percentage
                if product.actual_price.to_i > 0
                  product.discount_percentage = ((product.actual_price.to_f-product.discount_price.to_f)*100.00/product.actual_price.to_f).round
                end


                product.status = 1 if product.name.present? && product.primary_image_url.present? && product.discount_price.present?
                puts "----start_index/GlobalConstant::PRODUCTS_PER_EACH_LEVEL------#{(start_index/GlobalConstant::PRODUCTS_PER_EACH_LEVEL)+1}"
                product.priority = (start_index/GlobalConstant::PRODUCTS_PER_EACH_LEVEL)+1
                puts "COmplete product--->>> #{product.inspect}"
              rescue Exception => e
                puts "------Exception in  firstcry Inner loop-----#{e.inspect}"
              end

              product.save

              if associate_categories
                categories = []
                doc.css("div.breadcurm_css a")[1..2].each do |category|
                  categories << category.inner_html.gsub("&gt;", "")
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
        end
      end
    rescue Exception => e
      puts "----Exception in firstcry Outer loop -----#{e.inspect}-----#{e.backtrace}"
      try_count += 1
      retry if try_count < 4
    end

    puts "----Ended the cron for firstcry crawl --- End Time #{Time.now}"
  end
end