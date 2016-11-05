function foo (x)
   print("\tfoo", x)
   return coroutine.yield(2*x)
 end
 
 co = coroutine.create(function (a,b)
	   print("[1 co-body]", a, b)
	   local r = foo(a+1)
	   print("[2 co-body]", r)
	   local r, s = coroutine.yield(a+b, a-b)
	   print("[3 co-body]", r, s)
	   return b, "end"
 end)

print("::: begin :::")
print("\n - step 1")
print("==>",  coroutine.resume(co, 1, 10) )

print("\n - step 2")
print("==>", coroutine.resume(co, "r"))

print("\n - step 3")
print("==>",  coroutine.resume(co, "x", "y") )

print("\n - step 4")
print("==>", coroutine.resume(co, "x", "y") )

print("\nend")
