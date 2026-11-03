-- Depois de criar e confirmar a conta do administrador no ProSpace Health,
-- substitua o e-mail abaixo e execute este SQL no Supabase.
update public.profiles
set role = 'admin'
where id = (
  select id from auth.users
  where lower(email) = lower('matheusblasquessantos@gmail.com')
);
