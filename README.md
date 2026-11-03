# ProSpace Health — Gestão de Unidades

Portal web administrativo separado do aplicativo do cidadão, pensado para computadores das unidades de saúde. Utiliza o mesmo projeto Supabase do ProSpace Health App e autenticação por perfil.

## Módulos incluídos

- **Visão geral:** indicadores de pacientes, atendimentos do dia, solicitações pendentes e campanhas ativas.
- **Pacientes:** cadastro, edição, busca, inativação/reativação, endereço, identificação e vínculo com a unidade.
- **Atendimentos:** consulta da agenda, pesquisa por protocolo/paciente e atualização do status (agendado, confirmado, concluído, não compareceu ou cancelado).
- **Solicitações:** triagem, atualização do status e atribuição de unidade pelo administrador geral.
- **Campanhas:** criação, edição, período, categoria, público-alvo, local, contato, publicação e desativação.
- **Agenda e horários:** criação de vagas por unidade/serviço/data/hora/capacidade, abertura e fechamento de horários.
- **Registros de saúde:** acompanhamento administrativo de exames, vacinações e solicitações/dispensação de medicamentos.
- **Comunicados:** envio de notificação no aplicativo para pacientes ativos com conta vinculada à unidade.
- **Relatórios:** indicadores por status e exportação CSV de pacientes, atendimentos, solicitações e campanhas.
- **Unidades e serviços:** cadastro e manutenção da rede e do catálogo global (administrador geral).
- **Equipe e acessos:** vincular contas existentes como atendentes por unidade e remover acesso (administrador geral).
- **Auditoria:** histórico de criação, alteração e remoção nas tabelas administrativas (administrador geral).

## 1. Pré-requisitos

- Um projeto Supabase já criado.
- O schema original do ProSpace Health já instalado no projeto Supabase.
- Python 3 instalado no Windows para iniciar o servidor local.
- Conta cadastrada no Supabase para cada administrador/atendente.

## 2. Instalar a migração de gestão no Supabase

1. Abra o arquivo `database/upgrade_gestao.sql`.
2. No Supabase, acesse **SQL Editor → New query**.
3. Cole o conteúdo inteiro e execute uma vez.
4. Se o projeto ainda não tiver o schema original do aplicativo, execute antes `database/schema_base.sql`.
5. Não execute `database/demo_seed_ficticio.sql` em produção. Ele contém unidades fictícias para testes.

A migração cria a tabela administrativa `patient_registry`, vínculo de atendentes às unidades, permissões RLS, extensão de campanhas, notificações por unidade e log de auditoria.

## 3. Liberar o primeiro administrador geral

A conta precisa existir primeiro em **Authentication → Users** e ter um perfil em `public.profiles` (o perfil é criado automaticamente pelo schema original quando uma conta é cadastrada).

No SQL Editor, execute este comando trocando o e-mail:

```sql
update public.profiles
set role = 'admin'
where id = (
  select id from auth.users
  where lower(email) = lower('SEU_EMAIL@EXEMPLO.COM')
);
```

Depois, saia do portal/app e entre novamente com esse usuário. O primeiro administrador poderá cadastrar as unidades, serviços e vincular os atendentes.

## 4. Configurar a conexão

O arquivo `supabase-config.js` já vem preenchido com a URL e a chave **pública** encontradas no pacote do aplicativo que foi enviado. Confirme se são do mesmo projeto Supabase usado no app. Caso tenha outro projeto, edite o arquivo ou execute `CONFIGURAR_SUPABASE.bat`.

```js
window.PROSPACE_CONFIG = {
  supabaseUrl: 'https://SEU-PROJETO.supabase.co',
  supabaseAnonKey: 'SUA_CHAVE_PUBLICA'
};
```

Use somente a chave `publishable` ou `anon`. **Nunca coloque a chave `service_role` no navegador.**

## 5. Iniciar no Windows

1. Extraia a pasta inteira `ProSpace_Health_Gestao`.
2. Dê dois cliques em `INICIAR_GESTAO.bat`.
3. O navegador abrirá `http://localhost:8090`.
4. Entre com a conta que recebeu perfil `admin` ou `health_worker`.
5. Não feche a janela do CMD enquanto estiver usando o portal.

Se a porta 8090 estiver ocupada, feche outro servidor local ou altere `8090` no arquivo `.bat` e no endereço mostrado.

## 6. Cadastrar e liberar atendentes

1. O colaborador deve criar uma conta normal pelo ProSpace Health App e confirmar o e-mail quando exigido pelo Supabase.
2. O administrador abre **Equipe e acessos → Vincular atendente**.
3. Informa o mesmo e-mail da conta e escolhe a unidade.
4. A conta passa a ter perfil `health_worker` e acesso apenas à unidade atribuída.

O portal não cria senha nem conta de autenticação de terceiros. Isso é intencional: criação de usuários de Auth com privilégios administrativos exige uma função de servidor protegida, nunca uma chave `service_role` no navegador. Ao remover o último vínculo de unidade, a conta permanece com perfil `health_worker`, mas sem acesso operacional; o administrador pode vinculá-la novamente quando necessário.

## 7. Como funciona o cadastro de pacientes

O portal cria registros administrativos em `patient_registry`. O cidadão pode ter esse cadastro mesmo sem conta no aplicativo. Quando ele criar uma conta no app com o mesmo CPF, um gatilho do banco tenta associar automaticamente os registros (desde que o CPF não esteja duplicado). Quando um paciente sem unidade marcada realiza o primeiro agendamento, o cadastro pode herdar a unidade desse atendimento; solicitações novas também herdam a unidade principal quando disponível.

Registros sem usuário vinculado podem ser pesquisados e atualizados pela equipe da unidade, mas não recebem notificações dentro do app nem registros digitais de exame/vacina/medicamento associados à conta até existir vínculo com `auth.users`.

## 8. Permissões

- `admin`: acesso global, gestão de unidades/serviços/equipe, fila geral e auditoria.
- `health_worker`: acesso aos registros da(s) unidade(s) vinculada(s), conforme RLS no banco.
- `citizen`: não tem acesso ao painel administrativo.

A proteção real é aplicada no Supabase por Row Level Security (RLS); esconder menus na interface não é considerado controle de segurança.

## 9. Importante antes de usar com dados reais

Este pacote é uma base funcional de desenvolvimento e operação assistida, **não uma certificação de software de saúde pronto para produção**. Antes de cadastrar pacientes reais, faça revisão profissional de segurança, LGPD, bases legais, perfis mínimos de acesso, logs, backups, retenção, resposta a incidentes, HTTPS e política de privacidade. Teste a migração em um projeto de homologação e confira as políticas com contas de administrador, atendente de unidades diferentes e cidadão.

O módulo de registros de saúde é deliberadamente administrativo e mínimo; não substitui prontuário clínico oficial, prescrição eletrônica, integração com e-SUS ou sistemas nacionais.
