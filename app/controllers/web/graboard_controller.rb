class Web::GraboardController < ApplicationController

  def index
    @sort_categories = Category.get_categories_for_sort
    @price_filter = GlobalConstant::PRICE_FILTER
  end

	def get_data
		products = Product.get_products({:category_id => 0, :start_range => 0, :end_range => 10000, :order_by => 'discount_price', :order_type => 'ASC'})[:products]
		categories = ProductCategory.where("product_id in (?)", products.collect(&:id))
		indexed_sites = Site.all.index_by(&:id)
		render :json => {:products => products, :indexed_sites => indexed_sites, :categories => categories}
	end

  def redirect_handler
    redirect_to :root if params[:rd_url].blank?

    product = Product.where(:url => params[:rd_url]).first

    redirect_to :root if product.nil?
			if ProductView.create(:product_id => product.id, :site_id => product.site_id, :ip_address => request.remote_ip)
				redirect_to (params[:rd_url].index("?") ? params[:rd_url] + "&gref=1" : params[:rd_url] + "?gref=")
			else
    end
  end

end
