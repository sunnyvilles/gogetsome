class Web::GraboardController < ApplicationController

  def index
    
  end
	def get_data
		products = Product.where("name is not null").limit(20).all
		categories = ProductCategory.where("product_id in (?)", products.collect(&:id))
		indexed_sites = Site.all.index_by(&:id)
		render :json => {:products => products, :indexed_sites => indexed_sites, :categories => categories}
	end
end
