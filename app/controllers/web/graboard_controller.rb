class Web::GraboardController < ApplicationController

  def index
    
  end
	def get_data
		products = Product.where("name is not null").limit(20).all
		indexed_sites = Site.all.index_by(&:id)
		render :json => {:products => Product.where("name is not null").limit(20).all, :indexed_sites => indexed_sites}
	end
end
