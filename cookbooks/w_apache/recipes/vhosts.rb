web_app "examplewebsite" do
  server_name "www.examplewebsite.com"
  server_aliases ["examplewebsite.com"]
  docroot "/websites"
  cookbook 'apache2'
end