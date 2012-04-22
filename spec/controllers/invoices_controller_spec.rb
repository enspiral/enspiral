require 'spec_helper'

describe InvoicesController do
  before(:each) do
    @person = Person.make!(:staff)
    @company = Company.make!
    CompanyMembership.make!(company:@company, person:@person, admin:true)
    @customer = Customer.make!(company: @company)
    sign_in @person.user
    @invoice = Invoice.make!(company:@company)
  end

  it 'indexes company invoices' do
    get :index, company_id: @company.id
    response.should be_success
    response.should render_template(:index)
    assigns(:invoices).should_not be_nil
  end

  it 'shows a company invoice' do
    get :show, company_id: @company.id, id: @invoice.id
    response.should be_success
    response.should render_template :show
    assigns(:invoice).should_not be_nil
  end

  it 'shows a new invoice form' do
    get :new, company_id: @company.id
    response.should be_success
    response.should render_template :new
    assigns(:invoice).should_not be_nil
  end

  it 'shows a edit invoice form' do
    get :edit, company_id: @company.id, id: @invoice.id
    response.should be_success
    response.should render_template :edit
    assigns(:invoice).should_not be_nil
  end

  it 'creates invoices' do
    lambda{
    post :create, invoice: {amount: 5,
                            customer_id: @customer.id,
                            date: '2011-11-11',
                            due: '2011-11-11'}, company_id: @company.id
    }.should change(Invoice, :count).by(1)
    response.should be_redirect
    assigns(:invoice).company.should == @company
  end

  it 'updates invoices' do
    put :update, invoice: {amount: 7}, company_id: @company.id, id: @invoice.id
    response.should be_redirect
    assigns(:invoice).amount.should == 7
  end

  describe "Post 'pay'" do
    it "should mark an invoice as paid" do
      post :pay, :id => @invoice.id, :company_id => @company.id

      assigns(:invoice).paid.should be_true
      response.should redirect_to [@company, @invoice]
    end
  end
end