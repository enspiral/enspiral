class InvoicesController < IntranetController
  before_filter :load_invoice, only: [:edit, :show, :update, :destroy, :disburse, :pay_and_disburse]

  def index
    @invoices = company_or_project.invoices.not_closed
  end

  def closed
    @invoices = company_or_project.invoices.closed
    render :index
  end

  def new
    if @project
      @invoice = Invoice.new(project_id: @project.id, customer_id: @project.customer.id)
    else
      @invoice = Invoice.new
    end
  end

  def edit
  end

  def create
    @invoice = company_or_project.invoices.build(params[:invoice])
    if @invoice.save
      redirect_to invoice_path(@invoice)
    else
      render :new
    end
  end

  def update
    @invoice.update_attributes(params[:invoice])
    if @invoice.save
      redirect_to invoice_path(@invoice)
    else
      render :edit
    end
  end

  def show
    @payment = Payment.new
    @invoice_allocation = InvoiceAllocation.new(invoice_id: @invoice.id)
  end

  def pay_and_disburse
    @payment = @invoice.payments.create!(amount: @invoice.amount_owing, paid_on: Date.today)
    success = @invoice.disburse!(current_person)

    if success
      flash[:notice] = "Successfully paid and disbused invoice"
    else
      flash[:alert] = 'Unable to disburse'
    end

    redirect_to invoices_path
  end

  def disburse
    if params[:invoice_allocation_id]
      @allocation = @invoice.allocations.find params[:invoice_allocation_id]
      type = 'allocation'
      success = @allocation.disburse!(current_person)
    else
      type = 'all allocations'
      success = @invoice.disburse!(current_person)
    end
    if success
      flash[:notice] = "Successfully disbused #{type}"
    else
      flash[:alert] = 'Unable to disburse'
    end
    redirect_to invoice_path(@invoice)
  end

  def destroy
    if @invoice.destroy
      flash[:notice] = "Invoice destroyed"
    else
      flash[:error] = "Could not destroy invoice"
    end
    redirect_to invoices_path
  end

  private
  def load_invoice
    @invoice = company_or_project.invoices.where(id: params[:id]).first
    unless @invoice
      flash[:notice] = 'invoice not found'
      redirect_to invoices_path
    end
  end

end
