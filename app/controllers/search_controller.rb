class SearchController < IntranetController
  def index
    @people = Person.search(params[:big_search], star: true)
    @admin_of_ids = current_person.company_adminships.map{|ca| ca.company_id}
    if current_user.admin?
      @invoices = Invoice.search(params[:big_search], star: true)
    elsif !current_person.company_adminships.blank?
      @invoices = Invoice.search(params[:big_search], star: true,
                                 :with => {company_id: @admin_of_ids}
                                )
    else
      @invoices = nil
    end
    if current_user.admin?
      @projects = Project.search(params[:big_search], star: true)
    elsif !current_person.company_adminships.blank?
      @projects = Project.search(params[:big_search], star: true,
                                 :with => {
                                   company_id: @admin_of_ids
                                 }
                              )
    else
      @projects = Project.search(params[:big_search], star: true,
                                 :with => {
                                   company_id: current_person.company_ids
                                 }
                              )
    end
  end
end