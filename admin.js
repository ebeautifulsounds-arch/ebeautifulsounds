(() => {
'use strict';
const URL='https://acjxegnfrbfnouzlltlf.supabase.co';
const KEY='sb_publishable_L5mSPosdediQqVIau0cvGw_3dFn0YyC';
const $=id=>document.getElementById(id);
const msg=(id,text,ok=false)=>{const el=$(id);if(el){el.textContent=text;el.classList.toggle('ok',ok)}};
function boot(){
if(!window.supabase || typeof window.supabase.createClient!=='function'){
msg('loginMsg','Maktabadda gelitaanka ma soo degin. Hubi internetka oo dib u fur bogga.');
return;
}
const sb=window.supabase.createClient(URL,KEY);
msg('loginMsg','Foomka gelitaanku waa diyaar. Geli email-ka iyo password-ka.');
let articles=[];
$('year').textContent=new Date().getFullYear();
const isRecovery=location.hash.includes('type=recovery');
if(isRecovery){$('loginView').hidden=true;$('recoveryView').hidden=false}
$('recoveryForm').addEventListener('submit',async e=>{e.preventDefault();const p=$('newPassword').value;if(p!==$('confirmPassword').value){msg('recoveryMsg','Labada password isma laha.');return}if(p.length<8){msg('recoveryMsg','Password-ku ha ahaado ugu yaraan 8 xaraf.');return}const {error}=await sb.auth.updateUser({password:p});if(error){msg('recoveryMsg','Password-ka lama beddeli karin: '+error.message);return}history.replaceState(null,'',location.pathname+location.search);$('recoveryView').hidden=true;$('loginView').hidden=false;$('password').value='';msg('loginMsg','Password-ka waa la beddelay. Hadda ku gal password-ka cusub.',true)});
function slugify(s){return s.toLocaleLowerCase().normalize('NFKD').replace(/[\u0300-\u036f]/g,'').replace(/[^a-z0-9]+/g,'-').replace(/^-|-$/g,'').slice(0,190)}
function esc(s){return String(s??'').replace(/[&<>"']/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]))}
async function checkAdmin(user){const {data,error}=await sb.from('admin_users').select('user_id').eq('user_id',user.id).maybeSingle();if(error||!data){await sb.auth.signOut();$('loginView').hidden=false;$('adminView').hidden=true;msg('loginMsg','Akoonkan looma oggola maamulka. Hubi in user_id lagu daray admin_users.');return false} $('loginView').hidden=true;$('adminView').hidden=false;$('whoami').textContent='Waxaad ku gashay: '+(user.email||'Admin');await Promise.all([loadArticles(),loadComments(),loadSubscribers()]);return true}
$('loginForm').addEventListener('submit',async e=>{e.preventDefault();const b=$('loginForm').querySelector('button[type=submit]');b.disabled=true;msg('loginMsg','Gelitaanka waa la hubinayaa…');try{const {data,error}=await sb.auth.signInWithPassword({email:$('email').value.trim(),password:$('password').value});if(error)throw error;await checkAdmin(data.user)}catch(err){msg('loginMsg',err.message==='Invalid login credentials'?'Email-ka ama password-ku waa khaldan yahay. Haddii aadan password lahayn, isticmaal “Password-ka ma illowday?”':'Gelitaanku wuu fashilmay: '+err.message)}finally{b.disabled=false}});
$('resetBtn').addEventListener('click',async()=>{const email=$('email').value.trim();if(!email){msg('loginMsg','Marka hore geli email-kaaga kore.');$('email').focus();return}const {error}=await sb.auth.resetPasswordForEmail(email,{redirectTo:location.origin+location.pathname});if(error){msg('loginMsg','Email-ka dib-u-dejinta lama diri karin: '+error.message);return}msg('loginMsg','Haddii email-ku sax yahay, hubi inbox-ka iyo spam-ka si aad u dejiso password cusub.',true)});
$('logoutBtn').addEventListener('click',async()=>{await sb.auth.signOut();$('adminView').hidden=true;$('loginView').hidden=false;$('password').value='';msg('loginMsg','Waad ka baxday maamulka.',true)});
$('title').addEventListener('input',()=>{if(!$('articleId').value||!$('slug').dataset.touched)$('slug').value=slugify($('title').value)});
$('slug').addEventListener('input',()=>{$('slug').dataset.touched='1'});
function resetEditor(){$('articleForm').reset();$('articleId').value='';$('author').value='Xogta Hub';$('readTime').value='4 daqiiqo';$('slug').dataset.touched='';$('editorTitle').textContent='Maqaal cusub';$('cancelEdit').hidden=true;msg('editorMsg','')}
$('cancelEdit').addEventListener('click',resetEditor);
$('articleForm').addEventListener('submit',async e=>{e.preventDefault();const id=$('articleId').value;const title=$('title').value.trim();const status=$('status').value;const existingArticle=id?articles.find(a=>String(a.id)===String(id)):null;const payload={title,slug:slugify($('slug').value),category:$('category').value,description:$('description').value.trim(),content:$('content').value.trim(),image_url:$('imageUrl').value.trim()||null,author_name:$('author').value.trim()||'Xogta Hub',read_time:$('readTime').value.trim()||'4 daqiiqo',status,published_at:status==='published'?(existingArticle?.published_at||new Date().toISOString()):null,updated_at:new Date().toISOString()};if(!payload.slug){msg('editorMsg','Fadlan geli cinwaan ama slug sax ah.');return}const b=$('articleForm').querySelector('button[type=submit]');b.disabled=true;try{const result=id?await sb.from('articles').update(payload).eq('id',id).select('id').single():await sb.from('articles').insert(payload).select('id').single();if(result.error)throw result.error;msg('editorMsg',status==='published'?'Maqaalka waa la kaydiyay oo la daabacay.':'Maqaalka waa la kaydiyay (qabyo).',true);resetEditor();await loadArticles()}catch(err){console.error(err);msg('editorMsg','Kaydintu way fashilantay: '+err.message+' — Hubi RLS/policies-ka articles.')}finally{b.disabled=false}});
async function loadArticles(){ $('articleList').innerHTML='<p class="muted">Waa la soo rarayaa…</p>';const {data,error}=await sb.from('articles').select('id,title,slug,category,status,created_at,published_at').order('created_at',{ascending:false}).limit(200);if(error){$('articleList').innerHTML='<p class="message">Maqaalada lama soo rari karin: '+esc(error.message)+'</p>';return}articles=data||[];$('totalCount').textContent=articles.length;$('publishedCount').textContent=articles.filter(a=>a.status==='published').length;$('articleList').innerHTML=articles.length?articles.map(a=>'<article class="article-row"><h3>'+esc(a.title)+'</h3><div class="meta">'+esc(a.category)+' · <span class="pill '+(a.status==='draft'?'draft':'')+'">'+(a.status==='draft'?'Qabyo':'La daabacay')+'</span></div><div class="rowactions"><button class="editbtn" data-edit="'+esc(a.id)+'">Tafatir</button><button class="deletebtn" data-delete="'+esc(a.id)+'">Tirtir</button></div></article>').join(''):'<p class="muted">Weli maqaal ma jiro.</p>'}
$('articleList').addEventListener('click',async e=>{const edit=e.target.closest('[data-edit]'),del=e.target.closest('[data-delete]');if(edit){const a=articles.find(x=>String(x.id)===edit.dataset.edit);if(!a)return;const {data,error}=await sb.from('articles').select('*').eq('id',a.id).single();if(error){msg('editorMsg','Maqaalka lama furin: '+error.message);return}const x=data; $('articleId').value=x.id;$('title').value=x.title||'';$('slug').value=x.slug||'';$('slug').dataset.touched='1';$('category').value=x.category||'ai';$('description').value=x.description||'';$('content').value=x.content||'';$('imageUrl').value=x.image_url||'';$('author').value=x.author_name||'Xogta Hub';$('readTime').value=x.read_time||'4 daqiiqo';$('status').value=x.status||'draft';$('editorTitle').textContent='Tafatir maqaal';$('cancelEdit').hidden=false;window.scrollTo({top:0,behavior:'smooth'})}if(del){const a=articles.find(x=>String(x.id)===del.dataset.delete);if(!a||!confirm('Ma hubtaa inaad tirtirayso maqaalka “'+a.title+'”?'))return;const {error}=await sb.from('articles').delete().eq('id',a.id);if(error){alert('Tirtiriddu way fashilantay: '+error.message);return}await loadArticles()}});
async function loadComments(){
 const box=$('commentList');if(!box)return;
 box.innerHTML='<p class="muted">Faallooyinka waa la soo rarayaa…</p>';
 const {data,error}=await sb.from('comments').select('id,article_id,author_name,body,status,created_at,articles(title)').order('created_at',{ascending:false}).limit(100);
 if(error){box.innerHTML='<p class="message">Faallooyinka lama soo rari karin: '+esc(error.message)+'</p>';return}
 const rows=data||[];
 const pending=rows.filter(c=>c.status==='pending').length;
 $('pendingComments').textContent=pending;
 box.innerHTML=rows.length?rows.map(c=>'<article class="article-row"><h3>'+esc(c.author_name)+' · '+esc(c.articles?.title||'Maqaal la waayay')+'</h3><p>'+esc(c.body)+'</p><div class="meta">'+esc(new Date(c.created_at).toLocaleString('so-SO'))+' · <span class="pill '+(c.status==='pending'?'draft':'')+'">'+esc(c.status)+'</span></div><div class="rowactions">'+(c.status!=='approved'?'<button class="editbtn" data-comment-status="approved" data-comment-id="'+esc(c.id)+'">Ansixi</button>':'')+(c.status!=='rejected'?'<button class="secondary" data-comment-status="rejected" data-comment-id="'+esc(c.id)+'">Diid</button>':'')+'<button class="deletebtn" data-comment-delete="'+esc(c.id)+'">Tirtir</button></div></article>').join(''):'<p class="muted">Weli faallo ma jirto.</p>';
}
$('commentList').addEventListener('click',async e=>{
 const action=e.target.closest('[data-comment-status]'),del=e.target.closest('[data-comment-delete]');
 if(action){const id=action.dataset.commentId,status=action.dataset.commentStatus;action.disabled=true;const {error}=await sb.from('comments').update({status}).eq('id',id);if(error){msg('commentsMsg','Faallada lama beddeli karin: '+error.message);action.disabled=false;return}msg('commentsMsg',status==='approved'?'Faallada waa la ansixiyay.':'Faallada waa la diiday.',true);await loadComments()}
 if(del){const id=del.dataset.commentDelete;if(!confirm('Ma hubtaa inaad tirtirayso faalladan?'))return;const {error}=await sb.from('comments').delete().eq('id',id);if(error){msg('commentsMsg','Faallada lama tirtiri karin: '+error.message);return}msg('commentsMsg','Faallada waa la tirtiray.',true);await loadComments()}
});
$('refreshCommentsBtn').addEventListener('click',loadComments);
async function loadSubscribers(){
 const box=$('subscriberList');if(!box)return;
 box.innerHTML='<p class="muted">Liiska isdiiwaangelinta waa la soo rarayaa…</p>';
 const {data,error}=await sb.from('newsletter_subscribers').select('id,email,created_at').order('created_at',{ascending:false}).limit(500);
 if(error){box.innerHTML='<p class="message">Liiska email-lada lama soo rari karin: '+esc(error.message)+'</p>';return}
 const rows=data||[];$('subscriberCount').textContent=rows.length;
 box.innerHTML=rows.length?'<div class="subscriber-list">'+rows.map(s=>'<div class="subscriber-row"><strong>'+esc(s.email)+'</strong><span class="meta">'+esc(new Date(s.created_at).toLocaleDateString('so-SO'))+'</span></div>').join('')+'</div>':'<p class="muted">Weli qof isma diiwaangelin.</p>';
}
$('refreshSubscribersBtn').addEventListener('click',loadSubscribers);


$('refreshBtn').addEventListener('click',loadArticles);
sb.auth.getSession().then(({data})=>{if(data.session?.user)checkAdmin(data.session.user)});
sb.auth.onAuthStateChange((_event,session)=>{if(!session){$('adminView').hidden=true;$('loginView').hidden=false}});
 }
function safeBoot(){try{boot()}catch(error){console.error('Xogta Hub admin initialization error',error);msg('loginMsg','Bogga maamulka si buuxda uma furmin: '+(error?.message||'qalad aan la aqoon')+'. Dib u cusboonaysii bogga.')}}
if(window.supabase && typeof window.supabase.createClient==='function'){
safeBoot();
}else{
const fallback=document.createElement('script');
fallback.src='https://unpkg.com/@supabase/supabase-js@2';
fallback.onload=safeBoot;
fallback.onerror=()=>msg('loginMsg','Adeegga gelitaanka lama soo dejin karin. Hubi internetka, kadib dib u fur bogga.');
document.head.appendChild(fallback);
}
})();