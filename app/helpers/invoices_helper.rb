module InvoicesHelper
  def invoices_path(action_or_options = nil)
    if action_or_options.respond_to?(:to_hash)
      options = action_or_options
    else
      options = {action: action_or_options}
    end
    polymorphic_path([company_or_project, Invoice], options)
  end

  def invoice_path(invoice, action_or_options = nil)
    if action_or_options.respond_to?(:to_hash)
      options = action_or_options
    else
      options = {action: action_or_options}
    end
    polymorphic_path([company_or_project, invoice], options)
  end

  def pay_and_disburse_options(invoice)
    options = {}
    options[:method] = :post
    options[:confirm] = "Has a payment of #{number_to_currency(invoice.amount_owing)} been made? The allocated funds will be disbursed."
    options[:class] = :btn
    options
  end

  def disburse_options(invoice)
    options = []
    options[:method] = :post
    options[:confirm] = "The funds will be disbursed according to the allocations. Continue?"
    options[:class] = :btn
    options
  end

  def delete_options(invoice)
    {:confirm => "Are you sure?", :method => :delete, class: 'btn'}
  end
end
