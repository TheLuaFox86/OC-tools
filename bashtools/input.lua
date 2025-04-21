local a = table.pack(...)
io.write(a[1] .. ": ")
os.setenv(a[2], io.read("*Line")