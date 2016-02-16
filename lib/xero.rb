module Xero

  def xero?
    xero_consumer_key.present? && xero_consumer_secret.present?
  end

  def xero
    @xero ||= Xeroizer::PrivateApplication.new(xero_consumer_key, xero_consumer_secret, "#{Rails.root}/config/xero/privatekey.pem", :rate_limit_sleep => 3)
  end

  def get_invoice_from_xero_and_update
    # from = Invoice.where("xero_reference <> ''").first.date.beginning_of_day.to_s.split(" ")[0..1].join("T")
    xero_ref = Invoice.where(:imported => true).first.xero_reference
    xero_invoice = self.xero.Invoice.find("INV-#{xero_ref}")
    if xero_invoice
      xero_date = (xero_invoice.date - 1.month).beginning_of_month
    end
    invoices = self.xero.Invoice.all(:where => {:date_is_greater_than_or_equal_to => xero_date, :type => "ACCREC"})
    Invoice.insert_new_invoice invoices
  end

  def check_invoice_and_update
    xero_ref = Invoice.where(:imported => true).first.xero_reference
    xero_invoice = self.xero.Invoice.find("INV-#{xero_ref}")
    if xero_invoice
      xero_date = (xero_invoice.date - 2.month).beginning_of_month
    end
    invoices = self.xero.Invoice.all(:where => {:date_is_greater_than_or_equal_to => xero_date, :type => "ACCREC", :status => "AUTHORISED"})
    Invoice.update_existed_invoice invoices
  end

  def get_single_invoice_from_xero xero_ref
    invoices = self.xero.Invoice.find("INV-#{xero_ref}")
    # invoices = self.xero.Invoice.all(:where => {:invoice_number => "INV-#{xero_ref}"})
    Invoice.insert_single_invoice invoices
  end

  ############################## reporting ######################################

  def generate_manual_cash_position date_from, date_to
    result = []
    from = date_from.to_date
    to = date_to.to_date

    bank_balance = self.xero.BankSummary.get(:fromDate => from, :toDate => to).rows.last.rows.last.cells.last.value
    result << {"Bank Balance" => [bank_balance]}

    staff_accounts = self.accounts.not_closed.not_expense
    staff_accounts_balance = balance_for_accounts(staff_accounts, to)

    positive_accounts = staff_accounts.select {|ac| ac.balance > 0}
    positive_accounts_balance = balance_for_accounts(positive_accounts, to)
    result << {"Positive Accounts" => [positive_accounts_balance]}

    negative_accounts = staff_accounts.select {|ac| ac.balance < 0}
    negative_accounts_balance = balance_for_accounts(negative_accounts, to)
    result << {"- Negative Accounts" => [negative_accounts_balance * -1]}

    net_staff_accounts_balance = staff_accounts_balance
    ["Tax Paid", "Collective Funds", "Bucket", "Team"].each do |type_name|
      balance = balance_for_account_type(staff_accounts, type_name, to)
      net_staff_accounts_balance -= balance
      result << {" - '#{type_name}' Accounts" => [balance]}
    end

    result << {"Net Staff Accounts" => [net_staff_accounts_balance]}

    fund_after_paid_out = bank_balance - net_staff_accounts_balance
    result << {"Funds after staff paid out" => [fund_after_paid_out]}

    ytd_net_profit = self.xero.ProfitAndLoss.get(:fromDate => beginning_of_financial_year(date_from), :toDate => to).rows.last.rows.last.cells.last.value
    result << {"YTD Net Profit" => [ytd_net_profit]}

    result << {"- Net Staff Accounts" => [net_staff_accounts_balance]}

    net_profit = ytd_net_profit - net_staff_accounts_balance
    result << {"Net Profit/(Loss)" => [net_profit]}

    tax_to_date = net_profit - 72850.51 < 0 ? 0 : (net_profit - 72850.51) * 0.28
    result << {"Tax to date" => [tax_to_date]}

    # result
    result = result.inject{|memo, el| memo.merge( el ){|k, old_v, new_v| old_v + new_v}}
  end

end