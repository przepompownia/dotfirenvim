set noswapfile
let g:firenvim_config={'globalSettings':{},'localSettings':{'.*':{}}}
let g:firenvim_i=[]
let g:firenvim_o=[]
let g:Firenvim_oi={i,d,e->add(g:firenvim_i,d)}
let g:Firenvim_oo={t->[chansend(2,t)]+add(g:firenvim_o,t)}
let g:firenvim_c=stdioopen({'on_stdin':{i,d,e->g:Firenvim_oi(i,d,e)},'on_print':{t->g:Firenvim_oo(t)}})
let g:started_by_firenvim = v:true
