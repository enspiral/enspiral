class ReportsController < IntranetController
	def index
		@company = Company.find(params[:company_id])
		redirect_to cash_position_company_reports_path(@company)
	end

	def search
		account = Account.find_by_name("Collective Funds")
		@from = params[:from]
		@to = params[:to]
		@reports = account.get_contribution_reports params[:from], params[:to]
		render :index
	end

	def cash_position
		@title = "Enspiral Service: Monthly Cash Position"
		@company = Company.find(params[:company_id])
		@from = params[:from] ? params[:from] : Time.now.beginning_of_month.strftime("%d-%m-%Y")
		@to = params[:to] ? params[:to] : Time.now.end_of_month.strftime("%d-%m-%Y")
		date_from  = Date.parse(@from)
		date_to    = Date.parse(@to)
		date_range = date_from..date_to
		date_months = date_range.map {|d| Date.new(d.year, d.month, 1) }.uniq
		range_month = date_months.map {|d| d.strftime "%d-%m-%Y" }
		@date = date_months.map {|d| d.strftime "%B/%Y" }
		@reports = @company.generate_montly_cash_position range_month
		render :index
	end

	def contribution
		@type = params[:type] ? params[:type] : "Collective Funds"
		@title = "Monthly Contribution to #{@type}"
		@from = params[:from] ? params[:from] : Time.now.beginning_of_month.strftime("%d-%m-%Y")
		@to = params[:to] ? params[:to] : Time.now.end_of_month.strftime("%d-%m-%Y")
		date_from  = Date.parse(@from)
		date_to    = Date.parse(@to)
		date_range = date_from..date_to
		date_months = date_range.map {|d| Date.new(d.year, d.month, 1) }.uniq
		range_month = date_months.map {|d| d.strftime "%d-%m-%Y" }
		@date = date_months.map {|d| d.strftime "%B/%Y" }
		if params[:type] == "Collective Funds"
			@reports = Account.get_contribution_reports  @from, @to
		else
			@reports = Account.get_team_contribution_reports params[:type], @from, @to
		end
		render :index
	end
end