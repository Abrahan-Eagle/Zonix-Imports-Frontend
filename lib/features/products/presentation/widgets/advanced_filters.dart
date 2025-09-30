import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/ui_constants.dart';
import '../../data/services/filter_cache_service.dart';
import '../providers/product_provider.dart';

/// Widget de filtros avanzados con rangos de precio
class AdvancedFilters extends StatefulWidget {
  final VoidCallback onClose;
  final VoidCallback onApply;

  const AdvancedFilters({
    super.key,
    required this.onClose,
    required this.onApply,
  });

  @override
  State<AdvancedFilters> createState() => _AdvancedFiltersState();
}

class _AdvancedFiltersState extends State<AdvancedFilters>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  RangeValues _priceRange = const RangeValues(0, 1000);
  double _maxPrice = 1000;
  List<String> _selectedBrands = [];
  List<String> _selectedModalities = [];
  String? _selectedSort;
  bool _inStockOnly = false;
  bool _hasDiscount = false;

  // Lista de marcas disponibles (placeholder para futuras implementaciones)
  // final List<String> _brands = [
  //   'Apple', 'Samsung', 'Sony', 'LG', 'Microsoft', 'Google', 'Huawei', 'Xiaomi'
  // ];

  final List<String> _modalities = [
    'Detal',
    'Mayor',
    'Pre-order',
    'Referidos',
    'Dropshipping'
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: UIConstants.animationNormal,
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: UIConstants.curveEaseOut,
    ));

    _animationController.forward();
    _loadPriceRange();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _loadPriceRange() async {
    // En una implementación real, esto vendría de la API
    setState(() {
      _maxPrice = 5000;
      _priceRange = RangeValues(0, _maxPrice);
    });

    // Cargar filtros desde cache
    _loadFiltersFromCache();
  }

  /// Cargar filtros desde cache
  Future<void> _loadFiltersFromCache() async {
    try {
      final cachedFilters = await FilterCacheService.loadFiltersOrDefault();

      if (mounted) {
        setState(() {
          _priceRange = RangeValues(
            cachedFilters.minPrice ?? 0,
            cachedFilters.maxPrice ?? _maxPrice,
          );
          _selectedSort = cachedFilters.selectedSort;
          _inStockOnly = cachedFilters.inStockOnly;
          _hasDiscount = cachedFilters.hasDiscount;
          _selectedBrands = List.from(cachedFilters.selectedBrands);
          _selectedModalities = List.from(cachedFilters.selectedModalities);
        });

        // Aplicar automáticamente los filtros cargados desde cache
        _applyFiltersFromCache(cachedFilters);
      }
    } catch (e) {
      // Si hay error, usar valores por defecto
    }
  }

  /// Aplicar filtros desde cache al provider
  void _applyFiltersFromCache(FilterCache cachedFilters) {
    final provider = context.read<ProductProvider>();

    provider.applyFilters(
      minPrice: cachedFilters.minPrice,
      maxPrice: cachedFilters.maxPrice,
      inStockOnly: cachedFilters.inStockOnly,
      sortBy: cachedFilters.selectedSort,
      modalities: cachedFilters.selectedModalities,
      hasDiscount: cachedFilters.hasDiscount,
    );
  }

  void _applyFilters() {
    final provider = context.read<ProductProvider>();

    // Crear cache con los filtros actuales
    final filterCache = FilterCache(
      minPrice: _priceRange.start,
      maxPrice: _priceRange.end,
      selectedBrands: _selectedBrands,
      selectedModalities: _selectedModalities,
      selectedSort: _selectedSort,
      inStockOnly: _inStockOnly,
      hasDiscount: _hasDiscount,
    );

    // Guardar en cache
    FilterCacheService.saveFilters(filterCache);

    provider.applyFilters(
      minPrice: _priceRange.start,
      maxPrice: _priceRange.end,
      inStockOnly: _inStockOnly,
      sortBy: _selectedSort,
    );

    widget.onApply();
  }

  void _clearFilters() {
    setState(() {
      _priceRange = RangeValues(0, _maxPrice);
      _selectedBrands.clear();
      _selectedModalities.clear();
      _selectedSort = null;
      _inStockOnly = false;
      _hasDiscount = false;
    });

    // Limpiar cache
    FilterCacheService.clearFilters();

    final provider = context.read<ProductProvider>();
    provider.clearFilters();
  }

  /// Guardar cambios de precio en cache
  void _savePriceToCache(double minPrice, double maxPrice) {
    final filterCache = FilterCache(
      minPrice: minPrice,
      maxPrice: maxPrice,
      selectedBrands: _selectedBrands,
      selectedModalities: _selectedModalities,
      selectedSort: _selectedSort,
      inStockOnly: _inStockOnly,
      hasDiscount: _hasDiscount,
    );
    FilterCacheService.saveFilters(filterCache);

    // Aplicar filtros inmediatamente al provider
    final provider = context.read<ProductProvider>();
    provider.applyFilters(
      minPrice: minPrice,
      maxPrice: maxPrice,
      inStockOnly: _inStockOnly,
      sortBy: _selectedSort,
      modalities: _selectedModalities,
      hasDiscount: _hasDiscount,
    );
  }

  /// Guardar cambios de ordenamiento en cache
  void _saveSortToCache(String? sortValue) {
    final filterCache = FilterCache(
      minPrice: _priceRange.start,
      maxPrice: _priceRange.end,
      selectedBrands: _selectedBrands,
      selectedModalities: _selectedModalities,
      selectedSort: sortValue,
      inStockOnly: _inStockOnly,
      hasDiscount: _hasDiscount,
    );
    FilterCacheService.saveFilters(filterCache);

    // Aplicar filtros inmediatamente al provider
    final provider = context.read<ProductProvider>();
    provider.applyFilters(
      minPrice: _priceRange.start,
      maxPrice: _priceRange.end,
      inStockOnly: _inStockOnly,
      sortBy: sortValue,
      modalities: _selectedModalities,
      hasDiscount: _hasDiscount,
    );
  }

  /// Guardar cambios de stock en cache
  void _saveStockToCache(bool inStockOnly) {
    final filterCache = FilterCache(
      minPrice: _priceRange.start,
      maxPrice: _priceRange.end,
      selectedBrands: _selectedBrands,
      selectedModalities: _selectedModalities,
      selectedSort: _selectedSort,
      inStockOnly: inStockOnly,
      hasDiscount: _hasDiscount,
    );
    FilterCacheService.saveFilters(filterCache);

    // Aplicar filtros inmediatamente al provider
    final provider = context.read<ProductProvider>();
    provider.applyFilters(
      minPrice: _priceRange.start,
      maxPrice: _priceRange.end,
      inStockOnly: inStockOnly,
      sortBy: _selectedSort,
      modalities: _selectedModalities,
      hasDiscount: _hasDiscount,
    );
  }

  /// Guardar cambios de modalidades en cache
  void _saveModalitiesToCache(List<String> modalities) {
    final filterCache = FilterCache(
      minPrice: _priceRange.start,
      maxPrice: _priceRange.end,
      selectedBrands: _selectedBrands,
      selectedModalities: modalities,
      selectedSort: _selectedSort,
      inStockOnly: _inStockOnly,
      hasDiscount: _hasDiscount,
    );
    FilterCacheService.saveFilters(filterCache);

    // Aplicar filtros inmediatamente al provider
    final provider = context.read<ProductProvider>();
    provider.applyFilters(
      minPrice: _priceRange.start,
      maxPrice: _priceRange.end,
      inStockOnly: _inStockOnly,
      sortBy: _selectedSort,
      modalities: modalities,
      hasDiscount: _hasDiscount,
    );
  }

  /// Guardar cambios de descuento en cache
  void _saveDiscountToCache(bool hasDiscount) {
    final filterCache = FilterCache(
      minPrice: _priceRange.start,
      maxPrice: _priceRange.end,
      selectedBrands: _selectedBrands,
      selectedModalities: _selectedModalities,
      selectedSort: _selectedSort,
      inStockOnly: _inStockOnly,
      hasDiscount: hasDiscount,
    );
    FilterCacheService.saveFilters(filterCache);

    // Aplicar filtros inmediatamente al provider
    final provider = context.read<ProductProvider>();
    provider.applyFilters(
      minPrice: _priceRange.start,
      maxPrice: _priceRange.end,
      inStockOnly: _inStockOnly,
      sortBy: _selectedSort,
      modalities: _selectedModalities,
      hasDiscount: hasDiscount,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenHeight = MediaQuery.of(context).size.height;

    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        height: screenHeight * 0.85,
        decoration: BoxDecoration(
          color: isDark ? UIConstants.cardBgDark : UIConstants.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(UIConstants.radiusLG),
            topRight: Radius.circular(UIConstants.radiusLG),
          ),
        ),
        child: Column(
          children: [
            _buildHeader(context, isDark),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(UIConstants.spacingMD),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPriceRangeFilter(context, isDark),
                    const SizedBox(height: UIConstants.spacingLG),
                    _buildSortFilter(context, isDark),
                    const SizedBox(height: UIConstants.spacingLG),
                    _buildStockFilter(context, isDark),
                    const SizedBox(height: UIConstants.spacingLG),
                    _buildModalityFilter(context, isDark),
                    const SizedBox(height: UIConstants.spacingLG),
                    _buildDiscountFilter(context, isDark),
                    const SizedBox(height: UIConstants.spacingLG),
                  ],
                ),
              ),
            ),
            _buildActionButtons(context, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(UIConstants.spacingMD),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark ? UIConstants.grayDark : UIConstants.grayLight,
            width: UIConstants.borderThin,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Filtros Avanzados',
            style: TextStyle(
              fontSize: UIConstants.fontSizeLG,
              fontWeight: UIConstants.fontWeightBold,
              color: isDark ? UIConstants.textWhite : UIConstants.textPrimary,
            ),
          ),
          Row(
            children: [
              TextButton(
                onPressed: _clearFilters,
                child: Text(
                  'Limpiar',
                  style: TextStyle(
                    color: UIConstants.primaryBlue,
                    fontWeight: UIConstants.fontWeightMedium,
                  ),
                ),
              ),
              IconButton(
                onPressed: widget.onClose,
                icon: Icon(
                  Icons.close,
                  color:
                      isDark ? UIConstants.textWhite : UIConstants.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRangeFilter(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rango de Precio',
          style: TextStyle(
            fontSize: UIConstants.fontSizeMD,
            fontWeight: UIConstants.fontWeightBold,
            color: isDark ? UIConstants.textWhite : UIConstants.textPrimary,
          ),
        ),
        const SizedBox(height: UIConstants.spacingSM),
        Text(
          '\$${_priceRange.start.round()} - \$${_priceRange.end.round()}',
          style: TextStyle(
            fontSize: UIConstants.fontSizeSM,
            color: UIConstants.primaryBlue,
            fontWeight: UIConstants.fontWeightMedium,
          ),
        ),
        const SizedBox(height: UIConstants.spacingSM),
        RangeSlider(
          values: _priceRange,
          min: 0,
          max: _maxPrice,
          divisions: 50,
          activeColor: UIConstants.primaryBlue,
          inactiveColor: isDark ? UIConstants.grayDark : UIConstants.grayLight,
          onChanged: (RangeValues values) {
            setState(() {
              _priceRange = values;
            });
            // Guardar cambios de precio en cache
            _savePriceToCache(values.start, values.end);
          },
        ),
      ],
    );
  }

  Widget _buildSortFilter(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ordenar por',
          style: TextStyle(
            fontSize: UIConstants.fontSizeMD,
            fontWeight: UIConstants.fontWeightBold,
            color: isDark ? UIConstants.textWhite : UIConstants.textPrimary,
          ),
        ),
        const SizedBox(height: UIConstants.spacingSM),
        Wrap(
          spacing: UIConstants.spacingSM,
          runSpacing: UIConstants.spacingXS,
          children: [
            _buildSortChip('Nombre', 'name', isDark),
            _buildSortChip('Precio', 'price', isDark),
            _buildSortChip('Más recientes', 'created_at', isDark),
            _buildSortChip('Más vendidos', 'popularity', isDark),
            _buildSortChip('Mejor calificados', 'rating', isDark),
          ],
        ),
      ],
    );
  }

  Widget _buildSortChip(String label, String value, bool isDark) {
    final isSelected = _selectedSort == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedSort = selected ? value : null;
        });
        // Guardar cambios de ordenamiento en cache
        _saveSortToCache(selected ? value : null);
      },
      selectedColor: UIConstants.primaryBlue.withOpacity(0.2),
      checkmarkColor: UIConstants.primaryBlue,
      backgroundColor:
          isDark ? UIConstants.backgroundDark : UIConstants.grayLight,
      labelStyle: TextStyle(
        color: isSelected
            ? UIConstants.primaryBlue
            : (isDark ? UIConstants.textWhite : UIConstants.textPrimary),
        fontSize: UIConstants.fontSizeSM,
      ),
    );
  }

  Widget _buildStockFilter(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Disponibilidad',
          style: TextStyle(
            fontSize: UIConstants.fontSizeMD,
            fontWeight: UIConstants.fontWeightBold,
            color: isDark ? UIConstants.textWhite : UIConstants.textPrimary,
          ),
        ),
        const SizedBox(height: UIConstants.spacingSM),
        SwitchListTile(
          title: Text(
            'Solo productos en stock',
            style: TextStyle(
              color: isDark ? UIConstants.textWhite : UIConstants.textPrimary,
            ),
          ),
          subtitle: Text(
            'Mostrar únicamente productos disponibles',
            style: TextStyle(
              color: isDark ? Colors.white70 : UIConstants.textSecondary,
              fontSize: UIConstants.fontSizeXS,
            ),
          ),
          value: _inStockOnly,
          onChanged: (value) {
            setState(() {
              _inStockOnly = value;
            });
            // Guardar cambios de stock en cache
            _saveStockToCache(value);
          },
          activeColor: UIConstants.primaryBlue,
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }

  Widget _buildModalityFilter(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Modalidad de Venta',
          style: TextStyle(
            fontSize: UIConstants.fontSizeMD,
            fontWeight: UIConstants.fontWeightBold,
            color: isDark ? UIConstants.textWhite : UIConstants.textPrimary,
          ),
        ),
        const SizedBox(height: UIConstants.spacingSM),
        Wrap(
          spacing: UIConstants.spacingSM,
          runSpacing: UIConstants.spacingXS,
          children: _modalities.map((modality) {
            final isSelected = _selectedModalities.contains(modality);
            return FilterChip(
              label: Text(modality),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedModalities.add(modality);
                  } else {
                    _selectedModalities.remove(modality);
                  }
                });
                // Guardar cambios de modalidades en cache
                _saveModalitiesToCache(_selectedModalities);
              },
              selectedColor: UIConstants.primaryBlue.withOpacity(0.2),
              checkmarkColor: UIConstants.primaryBlue,
              backgroundColor:
                  isDark ? UIConstants.backgroundDark : UIConstants.grayLight,
              labelStyle: TextStyle(
                color: isSelected
                    ? UIConstants.primaryBlue
                    : (isDark
                        ? UIConstants.textWhite
                        : UIConstants.textPrimary),
                fontSize: UIConstants.fontSizeSM,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDiscountFilter(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ofertas Especiales',
          style: TextStyle(
            fontSize: UIConstants.fontSizeMD,
            fontWeight: UIConstants.fontWeightBold,
            color: isDark ? UIConstants.textWhite : UIConstants.textPrimary,
          ),
        ),
        const SizedBox(height: UIConstants.spacingSM),
        SwitchListTile(
          title: Text(
            'Solo productos con descuento',
            style: TextStyle(
              color: isDark ? UIConstants.textWhite : UIConstants.textPrimary,
            ),
          ),
          subtitle: Text(
            'Mostrar únicamente productos en oferta',
            style: TextStyle(
              color: isDark ? Colors.white70 : UIConstants.textSecondary,
              fontSize: UIConstants.fontSizeXS,
            ),
          ),
          value: _hasDiscount,
          onChanged: (value) {
            setState(() {
              _hasDiscount = value;
            });
            // Guardar cambios de descuento en cache
            _saveDiscountToCache(value);
          },
          activeColor: UIConstants.success,
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(UIConstants.spacingMD),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: isDark ? UIConstants.grayDark : UIConstants.grayLight,
            width: UIConstants.borderThin,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: widget.onClose,
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: isDark ? UIConstants.grayDark : UIConstants.gray,
                ),
                foregroundColor:
                    isDark ? UIConstants.textWhite : UIConstants.textPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(UIConstants.radiusMD),
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: UIConstants.spacingMD),
              ),
              child: const Text('Cancelar'),
            ),
          ),
          const SizedBox(width: UIConstants.spacingMD),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _applyFilters,
              style: ElevatedButton.styleFrom(
                backgroundColor: UIConstants.primaryBlue,
                foregroundColor: UIConstants.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(UIConstants.radiusMD),
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: UIConstants.spacingMD),
                elevation: UIConstants.elevationSM,
              ),
              child: const Text(
                'Aplicar Filtros',
                style: TextStyle(
                  fontWeight: UIConstants.fontWeightBold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
