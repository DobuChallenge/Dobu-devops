using Dobu.Domain.Commons;
using Dobu.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Dobu.Infrastructure.Persistence.Configurations;

public class UsuarioConfiguration : IEntityTypeConfiguration<Usuario>
{
    public void Configure(EntityTypeBuilder<Usuario> builder)
    {
        builder.ToTable("usuario");
        builder.HasKey(x => x.Id);
        builder.Property(x => x.Id).HasColumnName("id_usuario_pk");
        builder.Property(x => x.Nome).HasColumnName("nome_usuario").HasMaxLength(100).IsRequired();
        builder.Property(x => x.Email).HasColumnName("desc_email").HasMaxLength(150).IsRequired();
        builder.Property(x => x.Senha).HasColumnName("desc_senha").HasMaxLength(255).IsRequired();
        builder.Property(x => x.TipoUsuario).HasColumnName("tipo_usuario").HasMaxLength(20).IsRequired();
        builder.HasIndex(x => x.Email).IsUnique();
        BaseEntityConfiguration.Configure(builder);
    }
}

public class EspecieConfiguration : IEntityTypeConfiguration<Especie>
{
    public void Configure(EntityTypeBuilder<Especie> builder)
    {
        builder.ToTable("especie");
        builder.HasKey(x => x.Id);
        builder.Property(x => x.Id).HasColumnName("id_especie_pk");
        builder.Property(x => x.Nome).HasColumnName("nome_especie").HasMaxLength(80).IsRequired();
        builder.Property(x => x.Descricao).HasColumnName("desc_especie").HasMaxLength(300).IsRequired();
        BaseEntityConfiguration.Configure(builder);
    }
}

public class RacaConfiguration : IEntityTypeConfiguration<Raca>
{
    public void Configure(EntityTypeBuilder<Raca> builder)
    {
        builder.ToTable("raca");
        builder.HasKey(x => x.Id);
        builder.Property(x => x.Id).HasColumnName("id_raca_pk");
        builder.Property(x => x.Nome).HasColumnName("nome_raca").HasMaxLength(80).IsRequired();
        builder.Property(x => x.Porte).HasColumnName("tipo_porte").HasMaxLength(20).IsRequired();
        builder.Property(x => x.ExpectativaVida).HasColumnName("numero_expectativa").IsRequired();
        builder.Property(x => x.Descricao).HasColumnName("desc_raca").HasMaxLength(300);
        builder.Property(x => x.Cuidados).HasColumnName("desc_cuidados").HasMaxLength(500);
        builder.Property(x => x.EspecieId).HasColumnName("id_especie_fk");
        builder.HasOne(x => x.Especie).WithMany(x => x.Racas).HasForeignKey(x => x.EspecieId).OnDelete(DeleteBehavior.Restrict);
        BaseEntityConfiguration.Configure(builder);
    }
}

public class PetConfiguration : IEntityTypeConfiguration<Pet>
{
    public void Configure(EntityTypeBuilder<Pet> builder)
    {
        builder.ToTable("pet");
        builder.HasKey(x => x.Id);
        builder.Property(x => x.Id).HasColumnName("id_pet_pk");
        builder.Property(x => x.Nome).HasColumnName("nome_pet").HasMaxLength(80).IsRequired();
        builder.Property(x => x.Idade).HasColumnName("numero_idade").IsRequired();
        builder.Property(x => x.RacaId).HasColumnName("id_raca_fk");
        builder.Property(x => x.ResponsavelId).HasColumnName("id_responsavel_fk");
        builder.HasOne(x => x.Raca).WithMany(x => x.Pets).HasForeignKey(x => x.RacaId).OnDelete(DeleteBehavior.Restrict);
        builder.HasOne(x => x.Responsavel).WithMany(x => x.PetsResponsavel).HasForeignKey(x => x.ResponsavelId).OnDelete(DeleteBehavior.Restrict);
        BaseEntityConfiguration.Configure(builder);
    }
}

public class ConsultaConfiguration : IEntityTypeConfiguration<Consulta>
{
    public void Configure(EntityTypeBuilder<Consulta> builder)
    {
        builder.ToTable("consulta");
        builder.HasKey(x => x.Id);
        builder.Property(x => x.Id).HasColumnName("id_consulta_pk");
        builder.Property(x => x.DataConsulta).HasColumnName("data_consulta").IsRequired();
        builder.Property(x => x.Descricao).HasColumnName("desc_consulta").HasMaxLength(500).IsRequired();
        builder.Property(x => x.Valor).HasColumnName("valor_consulta").HasColumnType("numeric(10,2)").IsRequired();
        builder.Property(x => x.PetId).HasColumnName("id_pet_fk");
        builder.Property(x => x.VeterinarioId).HasColumnName("id_veterinario_fk");
        builder.HasOne(x => x.Pet).WithMany(x => x.Consultas).HasForeignKey(x => x.PetId).OnDelete(DeleteBehavior.Restrict);
        builder.HasOne(x => x.Veterinario).WithMany(x => x.ConsultasVeterinario).HasForeignKey(x => x.VeterinarioId).OnDelete(DeleteBehavior.Restrict);
        BaseEntityConfiguration.Configure(builder);
    }
}

public class AgendamentoConfiguration : IEntityTypeConfiguration<Agendamento>
{
    public void Configure(EntityTypeBuilder<Agendamento> builder)
    {
        builder.ToTable("agendamento");
        builder.HasKey(x => x.Id);
        builder.Property(x => x.Id).HasColumnName("id_agendamento_pk");
        builder.Property(x => x.DataAgendamento).HasColumnName("data_agendamento").IsRequired();
        builder.Property(x => x.Status).HasColumnName("status_agendamento").HasMaxLength(30).IsRequired();
        builder.Property(x => x.PetId).HasColumnName("id_pet_fk");
        builder.Property(x => x.VeterinarioId).HasColumnName("id_veterinario_fk");
        builder.HasOne(x => x.Pet).WithMany(x => x.Agendamentos).HasForeignKey(x => x.PetId).OnDelete(DeleteBehavior.Restrict);
        builder.HasOne(x => x.Veterinario).WithMany(x => x.AgendamentosVeterinario).HasForeignKey(x => x.VeterinarioId).OnDelete(DeleteBehavior.Restrict);
        BaseEntityConfiguration.Configure(builder);
    }
}

public class ProntuarioConfiguration : IEntityTypeConfiguration<Prontuario>
{
    public void Configure(EntityTypeBuilder<Prontuario> builder)
    {
        builder.ToTable("prontuario");
        builder.HasKey(x => x.Id);
        builder.Property(x => x.Id).HasColumnName("id_prontuario_pk");
        builder.Property(x => x.Diagnostico).HasColumnName("desc_diagnostico").HasMaxLength(500).IsRequired();
        builder.Property(x => x.Observacoes).HasColumnName("desc_observacoes").HasMaxLength(500);
        builder.Property(x => x.ConsultaId).HasColumnName("id_consulta_fk");
        builder.HasOne(x => x.Consulta).WithOne(x => x.Prontuario).HasForeignKey<Prontuario>(x => x.ConsultaId).OnDelete(DeleteBehavior.Restrict);
        BaseEntityConfiguration.Configure(builder);
    }
}

public class VacinaConfiguration : IEntityTypeConfiguration<Vacina>
{
    public void Configure(EntityTypeBuilder<Vacina> builder)
    {
        builder.ToTable("vacina");
        builder.HasKey(x => x.Id);
        builder.Property(x => x.Id).HasColumnName("id_vacina_pk");
        builder.Property(x => x.Nome).HasColumnName("nome_vacina").HasMaxLength(100).IsRequired();
        builder.Property(x => x.DataAplicacao).HasColumnName("data_aplicacao").IsRequired();
        builder.Property(x => x.DataProximaDose).HasColumnName("data_proxima_dose");
        builder.Property(x => x.PetId).HasColumnName("id_pet_fk");
        builder.HasOne(x => x.Pet).WithMany(x => x.Vacinas).HasForeignKey(x => x.PetId).OnDelete(DeleteBehavior.Restrict);
        BaseEntityConfiguration.Configure(builder);
    }
}

public class PagamentoConfiguration : IEntityTypeConfiguration<Pagamento>
{
    public void Configure(EntityTypeBuilder<Pagamento> builder)
    {
        builder.ToTable("pagamento");
        builder.HasKey(x => x.Id);
        builder.Property(x => x.Id).HasColumnName("id_pagamento_pk");
        builder.Property(x => x.Valor).HasColumnName("valor_pagamento").HasColumnType("numeric(10,2)").IsRequired();
        builder.Property(x => x.FormaPagamento).HasColumnName("tipo_forma_pagamento").HasMaxLength(40).IsRequired();
        builder.Property(x => x.DataPagamento).HasColumnName("data_pagamento").IsRequired();
        builder.Property(x => x.ConsultaId).HasColumnName("id_consulta_fk");
        builder.HasOne(x => x.Consulta).WithOne(x => x.Pagamento).HasForeignKey<Pagamento>(x => x.ConsultaId).OnDelete(DeleteBehavior.Restrict);
        BaseEntityConfiguration.Configure(builder);
    }
}

public class LembreteConfiguration : IEntityTypeConfiguration<Lembrete>
{
    public void Configure(EntityTypeBuilder<Lembrete> builder)
    {
        builder.ToTable("lembrete");
        builder.HasKey(x => x.Id);
        builder.Property(x => x.Id).HasColumnName("id_lembrete_pk");
        builder.Property(x => x.Descricao).HasColumnName("desc_lembrete").HasMaxLength(300).IsRequired();
        builder.Property(x => x.DataLembrete).HasColumnName("data_lembrete").IsRequired();
        builder.Property(x => x.Status).HasColumnName("status_lembrete").HasMaxLength(30).IsRequired();
        builder.Property(x => x.PetId).HasColumnName("id_pet_fk");
        builder.HasOne(x => x.Pet).WithMany(x => x.Lembretes).HasForeignKey(x => x.PetId).OnDelete(DeleteBehavior.Restrict);
        BaseEntityConfiguration.Configure(builder);
    }
}

public class DobuCamConfiguration : IEntityTypeConfiguration<DobuCam>
{
    public void Configure(EntityTypeBuilder<DobuCam> builder)
    {
        builder.ToTable("dobucam");
        builder.HasKey(x => x.Id);
        builder.Property(x => x.Id).HasColumnName("id_dobucam_pk");
        builder.Property(x => x.Localizacao).HasColumnName("desc_localizacao").HasMaxLength(150).IsRequired();
        builder.Property(x => x.StatusCamera).HasColumnName("status_camera").HasMaxLength(30).IsRequired();
        builder.Property(x => x.DataUltimaMovimentacao).HasColumnName("data_ultima_movimentacao");
        builder.Property(x => x.PetId).HasColumnName("id_pet_fk");
        builder.HasOne(x => x.Pet).WithMany(x => x.DobuCams).HasForeignKey(x => x.PetId).OnDelete(DeleteBehavior.Restrict);
        BaseEntityConfiguration.Configure(builder);
    }
}

public class AnaliseIaConfiguration : IEntityTypeConfiguration<AnaliseIa>
{
    public void Configure(EntityTypeBuilder<AnaliseIa> builder)
    {
        builder.ToTable("analise_ia");
        builder.HasKey(x => x.Id);
        builder.Property(x => x.Id).HasColumnName("id_analise_ia_pk");
        builder.Property(x => x.Descricao).HasColumnName("desc_analise").HasMaxLength(800).IsRequired();
        builder.Property(x => x.Risco).HasColumnName("numero_risco").IsRequired();
        builder.Property(x => x.DataAnalise).HasColumnName("data_analise").IsRequired();
        builder.Property(x => x.ProntuarioId).HasColumnName("id_prontuario_fk");
        builder.HasOne(x => x.Prontuario).WithOne(x => x.AnaliseIa).HasForeignKey<AnaliseIa>(x => x.ProntuarioId).OnDelete(DeleteBehavior.Restrict);
        BaseEntityConfiguration.Configure(builder);
    }
}

public class LogErroConfiguration : IEntityTypeConfiguration<LogErro>
{
    public void Configure(EntityTypeBuilder<LogErro> builder)
    {
        builder.ToTable("log_erro");
        builder.HasKey(x => x.Id);
        builder.Property(x => x.Id).HasColumnName("id_log_erro_pk");
        builder.Property(x => x.NomeProcedure).HasColumnName("nome_procedure").HasMaxLength(100).IsRequired();
        builder.Property(x => x.DescricaoErro).HasColumnName("desc_erro").HasMaxLength(1000).IsRequired();
        builder.Property(x => x.DataErro).HasColumnName("data_erro").IsRequired();
        builder.Property(x => x.UsuarioId).HasColumnName("id_usuario_fk");
        builder.HasOne(x => x.Usuario).WithMany(x => x.LogsErro).HasForeignKey(x => x.UsuarioId).OnDelete(DeleteBehavior.Restrict);
        BaseEntityConfiguration.Configure(builder);
    }
}

public class InformacaoCuidadoConfiguration : IEntityTypeConfiguration<InformacaoCuidado>
{
    public void Configure(EntityTypeBuilder<InformacaoCuidado> builder)
    {
        builder.ToTable("informacao_cuidado");
        builder.HasKey(x => x.Id);
        builder.Property(x => x.Id).HasColumnName("id_informacao_cuidado_pk");
        builder.Property(x => x.Titulo).HasColumnName("titulo").HasMaxLength(120).IsRequired();
        builder.Property(x => x.Descricao).HasColumnName("descricao").HasMaxLength(1000).IsRequired();
        builder.Property(x => x.PetId).HasColumnName("id_pet_fk");
        builder.HasOne(x => x.Pet).WithMany(x => x.InformacoesCuidado).HasForeignKey(x => x.PetId).OnDelete(DeleteBehavior.Cascade);
        BaseEntityConfiguration.Configure(builder);
    }
}

internal static class BaseEntityConfiguration
{
    public static void Configure<T>(EntityTypeBuilder<T> builder) where T : BaseEntity
    {
        builder.Property(x => x.CreatedAt).HasColumnName("created_at").IsRequired();
        builder.Property(x => x.Active)
            .HasColumnName("active")
            .IsRequired();
    }
}
