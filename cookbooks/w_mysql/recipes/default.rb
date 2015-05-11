mysql_service 'default' do
  bind_address '0.0.0.0' 
  data_dir '/data/db'
  action [:create, :start]
end

mysql_client 'default'
