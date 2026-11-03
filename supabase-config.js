// Chave pública do projeto Supabase compartilhado com o ProSpace Health.
// É seguro usar a chave publishable/anon no navegador, desde que o RLS esteja ativo.
// NUNCA coloque uma chave service_role neste arquivo.
window.PROSPACE_CONFIG = {
  supabaseUrl: 'https://qgsinijxsjesqedhxcms.supabase.co',
  supabaseAnonKey: 'sb_publishable_a3v0eIN5Sd2xRGvaqDxQRw_NccYJbHP'
};

// Mantém a sessão do Portal de Gestão separada da sessão do Portal do Cidadão,
// mesmo quando ambos são abertos no mesmo navegador.
if (window.supabase && typeof window.supabase.createClient === 'function') {
  const createSupabaseClient = window.supabase.createClient.bind(window.supabase);
  window.supabase.createClient = (url, anonKey, options = {}) => createSupabaseClient(url, anonKey, {
    ...options,
    auth: { ...(options.auth || {}), storageKey: 'prospace-gestao-auth' }
  });
}
