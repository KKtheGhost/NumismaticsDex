using Microsoft.UI.Windowing;
using Microsoft.UI;
using Microsoft.UI.Xaml;
using Microsoft.UI.Xaml.Controls;
using Microsoft.UI.Xaml.Media;
using Microsoft.UI.Xaml.Media.Imaging;
using NumismaticsDex.Core;
using Windows.Graphics;
using WinRT.Interop;

namespace NumismaticsDex.App;

public sealed partial class MainWindow : Window
{
    public CatalogViewModel ViewModel { get; } = new();
    private readonly BanknoteSourceService _sourceService = new();
    private readonly BanknoteImageService _imageService = new();
    private CancellationTokenSource? _imageLoadCancellation;
    private string _languageTag = "zh-CN";
    private bool _isDarkMode;
    private bool _isInitialized;
    private bool _isUpdatingHierarchy;

    public MainWindow()
    {
        InitializeComponent();
        _isInitialized = true;
        Title = "NumismaticsDex";
        ApplyLocalization();
        ApplyTheme(false);
        var initialSelection = ViewModel.InitialSelection;
        BanknoteList.SelectedItem = ViewModel.VisibleBanknotes.FirstOrDefault(entry => entry.Banknote.Id == initialSelection.Id);

        var windowId = Win32Interop.GetWindowIdFromWindow(WindowNative.GetWindowHandle(this));
        AppWindow.GetFromWindowId(windowId).Resize(new SizeInt32(1380, 860));
    }

    private void SearchBox_TextChanged(object sender, TextChangedEventArgs args)
    {
        RefreshSearch();
    }

    private void LanguageSelector_SelectionChanged(object sender, SelectionChangedEventArgs args)
    {
        if (!_isInitialized || LanguageSelector.SelectedItem is not ComboBoxItem item || item.Tag is not string languageTag)
        {
            return;
        }

        _languageTag = languageTag;
        ApplyLocalization();
        RefreshSearch();
    }

    private void RegionSelector_SelectionChanged(object sender, SelectionChangedEventArgs args)
    {
        if (!_isInitialized || _isUpdatingHierarchy || RegionSelector.SelectedItem is not string displayName)
        {
            return;
        }

        var region = ViewModel.RegionOptions.FirstOrDefault(option =>
            AppLocalization.RegionName(option, _languageTag) == displayName);
        if (region is null)
        {
            return;
        }

        ViewModel.SelectRegion(region);
        UpdateHierarchySelectors();
        RefreshSearch();
    }

    private void CountrySelector_SelectionChanged(object sender, SelectionChangedEventArgs args)
    {
        if (!_isInitialized || _isUpdatingHierarchy || CountrySelector.SelectedItem is not string displayName)
        {
            return;
        }

        var country = ViewModel.CountryOptions.FirstOrDefault(option =>
            AppLocalization.CountryName(option, _languageTag) == displayName);
        if (country is null)
        {
            return;
        }

        ViewModel.SelectCountry(country);
        UpdateHierarchySelectors();
        RefreshSearch();
    }

    private void CollectionSelector_SelectionChanged(object sender, SelectionChangedEventArgs args)
    {
        if (!_isInitialized || _isUpdatingHierarchy || CollectionSelector.SelectedItem is not string displayName)
        {
            return;
        }

        var collection = ViewModel.CollectionOptions.FirstOrDefault(option =>
            AppLocalization.CollectionTitle(option, _languageTag) == displayName);
        if (collection is null)
        {
            return;
        }

        ViewModel.SelectCollection(collection.Id);
        UpdateHierarchySelectors();
        RefreshSearch();
    }

    private void ThemeButton_Click(object sender, RoutedEventArgs args)
    {
        _isDarkMode = !_isDarkMode;
        ApplyTheme(_isDarkMode);
        ApplyThemeIcon();
    }

    private void RefreshSearch()
    {
        var selected = (BanknoteList.SelectedItem as BanknoteListEntry)?.Banknote;
        ViewModel.Filter(SearchBox.Text, _languageTag);
        CountText.Text = AppLocalization.CountLabel(ViewModel.VisibleBanknotes.Count, _languageTag);

        if (selected is null || !ViewModel.VisibleBanknotes.Any(entry => entry.Banknote.Id == selected.Id))
        {
            BanknoteList.SelectedItem = ViewModel.VisibleBanknotes.FirstOrDefault();
        }

        if (ViewModel.VisibleBanknotes.Count == 0)
        {
            DetailHeading.Text = AppLocalization.Get("noResults", _languageTag);
            FrontImage.Source = null;
            BackImage.Source = null;
        }
    }

    private void ApplyLocalization()
    {
        RootBorder.Language = _languageTag;
        Microsoft.UI.Xaml.Automation.AutomationProperties.SetName(LanguageSelector, AppLocalization.Get("languageSelector", _languageTag));
        ApplyLocalizedFont();
        AppSubtitleText.Text = AppLocalization.Get("subtitle", _languageTag);
        TopSummaryText.Text = AppLocalization.DemoSummary(ViewModel.TotalCount, _languageTag);
        BanknotesNavItem.Content = AppLocalization.Get("banknotes", _languageTag);
        CoinsNavItem.Content = AppLocalization.Get("coins", _languageTag);
        MedalsNavItem.Content = AppLocalization.Get("medals", _languageTag);
        CurrentTopicLabel.Text = AppLocalization.Get("browsePath", _languageTag);
        RegionSelectorLabel.Text = AppLocalization.Get("region", _languageTag);
        CountrySelectorLabel.Text = AppLocalization.Get("country", _languageTag);
        CollectionSelectorLabel.Text = AppLocalization.Get("collection", _languageTag);
        UpdateHierarchySelectors();
        SearchBox.PlaceholderText = AppLocalization.Get("search", _languageTag);
        FrontLabel.Text = AppLocalization.Get("front", _languageTag);
        BackLabel.Text = AppLocalization.Get("back", _languageTag);
        IssueInfoHeading.Text = AppLocalization.Get("issueInfo", _languageTag);
        IssuerLabel.Text = AppLocalization.Get("issuer", _languageTag);
        YearLabel.Text = AppLocalization.Get("year", _languageTag);
        IssueDateLabel.Text = AppLocalization.Get("issueDate", _languageTag);
        DescriptionLabel.Text = AppLocalization.Get("description", _languageTag);
        TagsLabel.Text = AppLocalization.Get("tags", _languageTag);
        ResearchSourceButton.Content = AppLocalization.Get("researchSource", _languageTag);
        PrinterLabel.Text = AppLocalization.Get("printer", _languageTag);
        SourceButton.Content = AppLocalization.Get("source", _languageTag);
        ApplyThemeIcon();
        RefreshButtonText.Text = AppLocalization.Get("refresh", _languageTag);
        Microsoft.UI.Xaml.Automation.AutomationProperties.SetName(RefreshButton, AppLocalization.Get("refresh", _languageTag));
        CountText.Text = AppLocalization.CountLabel(ViewModel.VisibleBanknotes.Count, _languageTag);
        Microsoft.UI.Xaml.Automation.AutomationProperties.SetName(FrontImage, AppLocalization.Get("front", _languageTag));
        Microsoft.UI.Xaml.Automation.AutomationProperties.SetName(BackImage, AppLocalization.Get("back", _languageTag));

        if (BanknoteList.SelectedItem is BanknoteListEntry entry)
        {
            ShowBanknote(entry.Banknote);
        }
    }

    private void ApplyLocalizedFont()
    {
        var familyName = _languageTag switch
        {
            "zh-CN" => "Microsoft YaHei UI",
            "zh-TW" => "Microsoft JhengHei UI",
            "ja-JP" => "Yu Gothic UI",
            _ => "Segoe UI"
        };
        var family = new FontFamily(familyName);
        ApplyFontToVisualTree(RootBorder, family);
    }

    private static void ApplyFontToVisualTree(DependencyObject element, FontFamily family)
    {
        if (element is TextBlock textBlock)
        {
            textBlock.FontFamily = family;
        }
        if (element is Control control && element is not FontIcon)
        {
            control.FontFamily = family;
        }

        for (var index = 0; index < VisualTreeHelper.GetChildrenCount(element); index++)
        {
            ApplyFontToVisualTree(VisualTreeHelper.GetChild(element, index), family);
        }
    }

    private void UpdateHierarchySelectors()
    {
        _isUpdatingHierarchy = true;
        try
        {
            RegionSelector.ItemsSource = ViewModel.RegionOptions
                .Select(region => AppLocalization.RegionName(region, _languageTag))
                .ToList();
            RegionSelector.SelectedItem = AppLocalization.RegionName(ViewModel.SelectedRegion, _languageTag);

            CountrySelector.ItemsSource = ViewModel.CountryOptions
                .Select(country => AppLocalization.CountryName(country, _languageTag))
                .ToList();
            CountrySelector.SelectedItem = AppLocalization.CountryName(ViewModel.SelectedCountry, _languageTag);

            CollectionSelector.ItemsSource = ViewModel.CollectionOptions
                .Select(collection => AppLocalization.CollectionTitle(collection, _languageTag))
                .ToList();
            CollectionSelector.SelectedItem = AppLocalization.CollectionTitle(ViewModel.SelectedCollection, _languageTag);
            CollectionDescriptionText.Text = ViewModel.SelectedCollection is { } collection
                ? AppLocalization.CollectionDescription(collection, _languageTag)
                : string.Empty;
        }
        finally
        {
            _isUpdatingHierarchy = false;
        }
    }

    private void ApplyTheme(bool isDark)
    {
        _isDarkMode = isDark;
        RootBorder.RequestedTheme = isDark ? ElementTheme.Dark : ElementTheme.Light;

        if (isDark)
        {
            SetBrushColor("PageBackgroundBrush", 25, 31, 29);
            SetBrushColor("SurfaceBrush", 34, 42, 39);
            SetBrushColor("InkBrush", 238, 243, 239);
            SetBrushColor("MutedBrush", 173, 188, 179);
            SetBrushColor("AccentBrush", 239, 158, 126);
            SetBrushColor("AccentSoftBrush", 75, 52, 43);
            SetBrushColor("LineBrush", 58, 72, 65);
            SetBrushColor("GreenBrush", 122, 198, 158);
            SetBrushColor("ErrorBrush", 255, 138, 128);
        }
        else
        {
            SetBrushColor("PageBackgroundBrush", 241, 244, 240);
            SetBrushColor("SurfaceBrush", 255, 255, 255);
            SetBrushColor("InkBrush", 23, 41, 35);
            SetBrushColor("MutedBrush", 100, 117, 109);
            SetBrushColor("AccentBrush", 168, 79, 53);
            SetBrushColor("AccentSoftBrush", 245, 232, 225);
            SetBrushColor("LineBrush", 221, 229, 223);
            SetBrushColor("GreenBrush", 39, 107, 85);
            SetBrushColor("ErrorBrush", 180, 35, 24);
        }
    }

    private void ApplyThemeIcon()
    {
        ThemeIcon.Glyph = _isDarkMode ? "\u2600" : "\u263E";
        var description = AppLocalization.Get(_isDarkMode ? "switchToLight" : "switchToDark", _languageTag);
        Microsoft.UI.Xaml.Automation.AutomationProperties.SetName(ThemeButton, description);
        ToolTipService.SetToolTip(ThemeButton, description);
    }

    private static void SetBrushColor(string key, byte red, byte green, byte blue)
    {
        if (Application.Current.Resources[key] is SolidColorBrush brush)
        {
            brush.Color = Windows.UI.Color.FromArgb(255, red, green, blue);
        }
    }

    private void BanknoteList_SelectionChanged(object sender, SelectionChangedEventArgs args)
    {
        if (BanknoteList.SelectedItem is BanknoteListEntry entry)
        {
            ShowBanknote(entry.Banknote);
        }
    }

    private void ShowBanknote(Banknote banknote)
    {
        _imageLoadCancellation?.Cancel();
        var imageLoadCancellation = new CancellationTokenSource();
        _imageLoadCancellation = imageLoadCancellation;

        DetailPick.Text = $"{banknote.PickLabel}  ·  {banknote.CountryCode}";
        DetailHeading.Text = AppLocalization.Issuer(banknote, _languageTag);
        DetailDenomination.Text = AppLocalization.Denomination(banknote, _languageTag);
        IssuerText.Text = AppLocalization.Issuer(banknote, _languageTag);
        YearText.Text = banknote.Year?.ToString() ?? AppLocalization.Get("unknown", _languageTag);
        IssueDateText.Text = AppLocalization.IssueDate(banknote, _languageTag);
        PrinterText.Text = AppLocalization.Printer(banknote, _languageTag);
        VariantText.Text = AppLocalization.Variant(banknote, _languageTag);
        ResearchText.Text = AppLocalization.ResearchDescription(banknote, _languageTag);
        TagsText.Text = AppLocalization.ResearchTags(banknote, _languageTag);
        var hasResearchTags = banknote.Research is { Tags.Count: > 0 };
        TagsLabel.Visibility = hasResearchTags ? Visibility.Visible : Visibility.Collapsed;
        TagsText.Visibility = hasResearchTags ? Visibility.Visible : Visibility.Collapsed;
        ResearchSourceButton.Tag = banknote.Research?.SourceUrl;
        ResearchSourceButton.IsEnabled = Uri.TryCreate(banknote.Research?.SourceUrl, UriKind.Absolute, out _);
        ResearchSourceButton.Visibility = ResearchSourceButton.IsEnabled ? Visibility.Visible : Visibility.Collapsed;
        ToolTipService.SetToolTip(ResearchSourceButton, AppLocalization.ResearchSourceName(banknote, _languageTag));
        FrontImage.Source = null;
        BackImage.Source = null;
        _ = LoadImagesAsync(banknote, imageLoadCancellation);
        SourceButton.Tag = banknote.SourceUrl;
        SourceButton.IsEnabled = Uri.TryCreate(banknote.SourceUrl, UriKind.Absolute, out _);
        RefreshButton.IsEnabled = BanknoteSourceService.CanRefresh(banknote);
        RefreshProgressRing.IsActive = false;
        RefreshStatusText.Text = string.Empty;
        RefreshStatusText.Foreground = (Brush)Application.Current.Resources["MutedBrush"];
        RefreshActivityPanel.Visibility = Visibility.Collapsed;
    }

    private async Task LoadImagesAsync(Banknote banknote, CancellationTokenSource cancellation)
    {
        try
        {
            await Task.WhenAll(
                LoadImageAsync(banknote, front: true, cancellation.Token),
                LoadImageAsync(banknote, front: false, cancellation.Token));
        }
        finally
        {
            if (ReferenceEquals(_imageLoadCancellation, cancellation))
            {
                _imageLoadCancellation = null;
            }

            cancellation.Dispose();
        }
    }

    private async Task LoadImageAsync(Banknote banknote, bool front, CancellationToken cancellationToken)
    {
        try
        {
            var imagePath = await _imageService.LoadAsync(banknote, front, cancellationToken);
            if (imagePath is null || cancellationToken.IsCancellationRequested)
            {
                return;
            }

            var bitmap = new BitmapImage
            {
                CreateOptions = BitmapCreateOptions.IgnoreImageCache,
                DecodePixelWidth = 960
            };
            bitmap.UriSource = new Uri(imagePath);

            if (front)
            {
                FrontImage.Source = bitmap;
            }
            else
            {
                BackImage.Source = bitmap;
            }
        }
        catch (OperationCanceledException)
        {
        }
        catch (HttpRequestException)
        {
        }
        catch (IOException)
        {
        }
    }

    private async void RefreshFromSource_Click(object sender, RoutedEventArgs args)
    {
        if (BanknoteList.SelectedItem is not BanknoteListEntry selectedEntry ||
            !BanknoteSourceService.CanRefresh(selectedEntry.Banknote))
        {
            return;
        }

        var banknote = selectedEntry.Banknote;

        RefreshButton.IsEnabled = false;
        RefreshProgressRing.IsActive = true;
        RefreshStatusText.Text = AppLocalization.Get("refreshing", _languageTag);
        RefreshStatusText.Foreground = (Brush)Application.Current.Resources["MutedBrush"];
        RefreshActivityPanel.Visibility = Visibility.Visible;

        try
        {
            var updated = await _sourceService.RefreshAsync(banknote);
            ViewModel.Replace(updated);
            ViewModel.Filter(SearchBox.Text, _languageTag);
            CountText.Text = AppLocalization.CountLabel(ViewModel.VisibleBanknotes.Count, _languageTag);
            BanknoteList.SelectedItem = ViewModel.VisibleBanknotes.FirstOrDefault(note => note.Banknote.Id == updated.Id);
            ShowBanknote(updated);
            RefreshStatusText.Text = AppLocalization.Get("refreshDone", _languageTag);
            RefreshStatusText.Foreground = (Brush)Application.Current.Resources["GreenBrush"];
            RefreshActivityPanel.Visibility = Visibility.Visible;
        }
        catch (Exception error)
        {
            RefreshStatusText.Text = AppLocalization.Get("refreshFailed", _languageTag);
            RefreshStatusText.Foreground = (Brush)Application.Current.Resources["ErrorBrush"];
            RefreshActivityPanel.Visibility = Visibility.Visible;
            ToolTipService.SetToolTip(RefreshStatusText, error.Message);
        }
        finally
        {
            RefreshProgressRing.IsActive = false;
            RefreshButton.IsEnabled = BanknoteSourceService.CanRefresh(banknote);
        }
    }

    private async void SourceButton_Click(object sender, RoutedEventArgs args)
    {
        if (SourceButton.Tag is string url && Uri.TryCreate(url, UriKind.Absolute, out var uri))
        {
            await Windows.System.Launcher.LaunchUriAsync(uri);
        }
    }

    private async void ResearchSourceButton_Click(object sender, RoutedEventArgs args)
    {
        if (ResearchSourceButton.Tag is string url && Uri.TryCreate(url, UriKind.Absolute, out var uri))
        {
            await Windows.System.Launcher.LaunchUriAsync(uri);
        }
    }
}