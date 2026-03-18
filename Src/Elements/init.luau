local Elements = {}

for _, Element in next, script:GetChildren() do
	table.insert(Elements, require(Element))
end

return Elements
