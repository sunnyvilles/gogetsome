class Web::GraboardController < ApplicationController

  def index
    
  end
	def get_data
		indexed_sites = Site.all.index_by(&:id)
		products = Product.where("name is not null").limit(20).all
		#product_ids = []
		#products.each{|product| product_ids.push(product.id)}
		#categories = ProductCategories.where("product_id is in ", )
		render :json => {:products => products, :indexed_sites => indexed_sites}
	end
end
