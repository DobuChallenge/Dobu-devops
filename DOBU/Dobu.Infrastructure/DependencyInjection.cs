using Dobu.Application.Interfaces.Repositories;
using Dobu.Application.Services;
using Dobu.Infrastructure.Persistence;
using Dobu.Infrastructure.Repositories;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;

namespace Dobu.Infrastructure;

public static class DependencyInjection
{
    public static IServiceCollection AddInfrastructure(this IServiceCollection services, IConfiguration configuration)
    {
        var provider = configuration["Database:Provider"] ?? "Sqlite";
        if (provider.Equals("Sqlite", StringComparison.OrdinalIgnoreCase))
        {
            var sqliteConn = configuration.GetConnectionString("DobuSqlite") ?? "Data Source=dobu.db";
            services.AddDbContext<DobuDbContext>(options =>
                options.UseSqlite(sqliteConn));
        }
        else if (provider.Equals("Postgres", StringComparison.OrdinalIgnoreCase) || provider.Equals("PostgreSQL", StringComparison.OrdinalIgnoreCase))
        {
            var postgresConn = configuration.GetConnectionString("DobuPostgres");
            if (string.IsNullOrWhiteSpace(postgresConn))
                throw new InvalidOperationException("Configure ConnectionStrings:DobuPostgres nas configurações seguras do ambiente.");

            services.AddDbContext<DobuDbContext>(options =>
                options.UseNpgsql(postgresConn, npgsql => npgsql.EnableRetryOnFailure()));
        }
        else
        {
            throw new InvalidOperationException("Database:Provider deve ser Sqlite ou Postgres.");
        }

        services.AddScoped<IAgendamentoRepository, AgendamentoRepository>();
        services.AddScoped<IAnaliseIaRepository, AnaliseIaRepository>();
        services.AddScoped<IConsultaRepository, ConsultaRepository>();
        services.AddScoped<IDobuCamRepository, DobuCamRepository>();
        services.AddScoped<IEspecieRepository, EspecieRepository>();
        services.AddScoped<ILembreteRepository, LembreteRepository>();
        services.AddScoped<ILogErroRepository, LogErroRepository>();
        services.AddScoped<IPagamentoRepository, PagamentoRepository>();
        services.AddScoped<IPetRepository, PetRepository>();
        services.AddScoped<IProntuarioRepository, ProntuarioRepository>();
        services.AddScoped<IRacaRepository, RacaRepository>();
        services.AddScoped<IUsuarioRepository, UsuarioRepository>();
        services.AddScoped<IUserStore, UserStore>();
        services.AddScoped<IVacinaRepository, VacinaRepository>();

        return services;
    }
}
