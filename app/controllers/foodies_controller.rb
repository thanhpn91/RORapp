
class FoodiesController < ApplicationController
  respond_to :html, :json
  before_action :set_foody, only: [:show, :edit, :update, :destroy]

  # GET /foodies
  # GET /foodies.json
  def index
    @foodies = Foody.all

  end

  # GET /foodies/1
  # GET /foodies/1.json
  def show
    @foody = Foody.find(params[:id])
    respond_to do |format|
     format.json { render :show, status: :created, location: @foody }
    end
  end

  # GET /foodies/new
  def new
    @foody = Foody.new
  end

  # GET /foodies/1/edit
  def edit
  end

  # POST /foodies
  # POST /foodies.json
  def create
    @foody = Foody.new(foody_params)

    respond_to do |format|
      if @foody.save
        format.html { redirect_to @foody, notice: 'Foody was successfully created.' }
        format.json { render :show, status: :created, location: @foody }
      else
        format.html { render :new }
        format.json { render json: @foody.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /foodies/1
  # PATCH/PUT /foodies/1.json
  def update
    respond_to do |format|
      if @foody.update(foody_params)
        format.html { redirect_to @foody, notice: 'Foody was successfully updated.' }
        format.json { render :show, status: :ok, location: @foody }
      else
        format.html { render :edit }
        format.json { render json: @foody.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /foodies/1
  # DELETE /foodies/1.json
  def destroy
    @foody.destroy
    respond_to do |format|
      format.html { redirect_to foodies_url, notice: 'Foody was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_foody
      @foody = Foody.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def foody_params
      params.require(:foody).permit(:title, :address, :description, :photos, :category)
    end
end
