class Myaccount::AddressesController < Myaccount::BaseController
  helper_method :countries
  def index
    @addresses = current_user.shipping_addresses
  end

  def show
    @address = current_user.addresses.find(params[:id])
  end

  def new
    form_info
    @address = Address.new
    if !HADEAN_CONFIG['require_state_in_address'] && HADEAN_CONFIG['available_country_ids_to_ship'].size == 1
      @address.country_id = HADEAN_CONFIG['available_country_ids_to_ship'].first
    end
    @address.default = true          if current_user.default_shipping_address.nil?
  end

  def create
    @address = current_user.addresses.new(params[:address])
    @address.default = true          if current_user.default_shipping_address.nil?
    @address.billing_default = true  if current_user.default_billing_address.nil?

    respond_to do |format|
      if @address.save_default_address(current_user, params[:address])
        format.html { redirect_to(myaccount_address_url(@address), :notice => 'Address was successfully created.') }
      else
        form_info
        format.html { render :action => "new" }
      end
    end
  end

  def edit
    form_info
    @address = current_user.addresses.find(params[:id])
  end

  def update
    @address = current_user.addresses.find(params[:id])
    if @address.save_default_address(current_user, params[:address])
      flash[:notice] = "Successfully updated address."
      redirect_to myaccount_address_url(@address)
    else
      form_info
      render :action => 'edit'
    end
  end

  def destroy
    @address = current_user.addresses.find(params[:id])
    @address.inactive!
    flash[:notice] = "Successfully destroyed address."
    redirect_to myaccount_addresses_url
  end

  private

  def form_info
    @states = State.form_selector
  end

  def countries
    @countries ||= Country.where(['id IN (?)', HADEAN_CONFIG['available_country_ids_to_ship']]).map{|sz| [sz.name, sz.id]}
  end

  def selected_myaccount_tab(tab)
    tab == 'address'
  end
end
