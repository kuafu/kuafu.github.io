co = coroutine.create(function ()
	print("co1")

	print("co2", coroutine.yield(1))
	print("co3")
end)

print(coroutine.resume(co))
print("hhhhhhhhhhhhh")
print(coroutine.resume(co, 4, 5) )


print("=============")