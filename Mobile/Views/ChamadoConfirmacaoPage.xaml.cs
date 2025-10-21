using System;
using System.Collections.Generic;
using Microsoft.Maui.Controls;
using SistemaChamados.Mobile.Helpers;
using SistemaChamados.Mobile.Models.DTOs;
using SistemaChamados.Mobile.ViewModels;

namespace SistemaChamados.Mobile.Views;

public partial class ChamadoConfirmacaoPage : ContentPage, IQueryAttributable
{
    private readonly ChamadoConfirmacaoViewModel _viewModel;

    public ChamadoConfirmacaoPage(ChamadoConfirmacaoViewModel? viewModel = null)
    {
        try
        {
            App.Log("ChamadoConfirmacaoPage constructor start");
            InitializeComponent();
            App.Log("ChamadoConfirmacaoPage InitializeComponent done");
            _viewModel = viewModel ?? ServiceHelper.GetService<ChamadoConfirmacaoViewModel>();
            App.Log("ChamadoConfirmacaoPage ViewModel resolved");
            BindingContext = _viewModel;
            App.Log("ChamadoConfirmacaoPage BindingContext set");
        }
        catch (Exception ex)
        {
            App.Log($"ChamadoConfirmacaoPage constructor FATAL: {ex}");
            throw;
        }
    }

    public void ApplyQueryAttributes(IDictionary<string, object> query)
    {
        try
        {
            App.Log("ChamadoConfirmacaoPage ApplyQueryAttributes start");
            if (query.TryGetValue("Chamado", out var chamadoObj) && chamadoObj is ChamadoDto chamado)
            {
                App.Log($"ChamadoConfirmacaoPage initializing with chamado Id: {chamado.Id}");
                _viewModel.Initialize(chamado);
                App.Log("ChamadoConfirmacaoPage initialization complete");
            }
            else
            {
                App.Log("ChamadoConfirmacaoPage ApplyQueryAttributes: no chamado found in query");
            }
        }
        catch (Exception ex)
        {
            App.Log($"ChamadoConfirmacaoPage ApplyQueryAttributes FATAL: {ex}");
            throw;
        }
    }
}
