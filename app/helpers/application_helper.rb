module ApplicationHelper
	def select_options_from_array(array, selected)
		html = ""
		array.each do |value|
			if (!selected.nil? && selected == value) 
				html = html + "<option selected>"
			else
				html = html + "<option>"
			end
			html = html + value.to_s + "</option>"
		end
		html.html_safe
	end
end
