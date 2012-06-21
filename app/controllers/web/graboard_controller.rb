class Web::GraboardController < ApplicationController

  def index
    
  end
  
	def get_data
		products = Product.where("name is not null").all
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
