dep 'agent99 dev' do
  requires 'ruby1.9.1-dev.managed',
           'libxml2-dev.managed',
           'libxslt1-dev.managed'
end

dep'ruby1.9.1-dev.managed' do
  provides ['ruby1.9.1']
end
dep'libxml2-dev.managed' do
  provides []
end
dep'libxslt1-dev.managed' do
  provides []
end
