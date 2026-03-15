try
  call firenvim#run()
catch /Unknown function/
  call chansend(g:firenvim_c,["f\n\n\n"..json_encode({"messages":["Your plugin manager did not load the Firenvim plugin for neovim."],"version":"0.0.0"})])
  call chansend(2,["Firenvim not in runtime path. &rtp="..&rtp])
  qall!
catch
  call chansend(g:firenvim_c,["l\n\n\n"..json_encode({"messages": ["Something went wrong when running firenvim. See troubleshooting guide."],"version":"0.0.0"})])
  call chansend(2,[v:exception])
  qall!
endtry
