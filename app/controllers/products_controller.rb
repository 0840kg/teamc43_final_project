
class ProductsController < ApplicationController
  #updateメソッド時も利用？
  before_action :image_confirmation, only: [:create]
  def index
    brand_ids    = Product.group(:brand_id).order('count_brand_id DESC').limit(2).count(:brand_id).keys
    category_ids = Product.group(:category_id).order('count_category_id DESC').limit(2).count(:category_id).keys
    @brands      = brand_ids.map { |id| Brand.find(id) }
    @categories  = category_ids.map { |id| Category.find(id) }
  end
  def new
    @product = Product.new
    # カテゴリーテーブルできるまでの仮置き
    @choices = {"---": 0, "レディース": 1,"メンズ":2}
  end
  def show
    @product = Product.find(params[:id])
    @images  = @product.p_images
    @similer_categories  = Product.where(category_id: @product.category_id).order('id ASC').limit(6)
    @user_products =Product.where(seller_id: @product.seller_id).limit(6)
  end
  def create
    @product = Product.new(create_params.merge(for_sale:1, deal: 0))
    if @product.save
      image_params[:p_images].each do |image|
        @product.p_images.build
        product_image = @product.p_images.new(image: image)
        product_image.save
      end
      respond_to do |format|
        format.json
      end
    end
  end
  def update
    if params[:p_image].present?
      @product = Product.find(params[:id])
      if @product.update(create_params.merge(for_sale:1, deal: 0))
        image_params[:p_images].each do |image|
          @product.p_images.build
          product_image = @product.p_images.new(image: image)
          product_image.save
        end
        respond_to do |format|
          format.json
        end
      end
    else
      @product = Product.find(params[:id])
      @product.update(create_params.merge(for_sale:1, deal: 0))
      respond_to do |format|
        format.json
      end
    end
  end
  def search
    @brands = Brand.where('name LIKE(?)', "%#{params[:keyword]}%").limit(10)
    respond_to do |format|
      format.html
      format.json
    end
  end
  def edit
    @product    = Product.find(params[:id])
    # カテゴリー機能作成まで借りで全て参照可能
    @categories = Category.all
    @sizes      = Size.all
    @brands     = Brand.all
  end


  private
  def create_params
      product_params = params.require(:product).permit(:name, :description,:category_id, :size, :brand_id, :condition, :select_shipping_fee, :shipping_method, :area, :shipping_date, :price).merge(seller_id: 1)
      # 新規作成画面がないためseller_idは仮置き
      product_params[:brand_id] = Brand.find_by(name: product_params[:brand_id]).id if product_params[:brand_id].present?
      return product_params
  end
  def image_params
    params.require(:p_image).permit({:p_images => []})
  end
  def image_confirmation
    if params[:p_image].present?
    else
      redirect_to new_product_path, alert: '入力に不備があります。必須項目を入力してください。'
    end
  end
end
