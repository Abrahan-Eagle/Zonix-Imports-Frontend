import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/ui_constants.dart';
import '../../data/models/product_model.dart';
import '../../data/services/search_service.dart';
import '../providers/product_provider.dart';

/// Widget de búsqueda mejorado con sugerencias en tiempo real
class EnhancedSearchBar extends StatefulWidget {
  final Function(String) onSearch;
  final Function(ProductModel) onProductTap;
  final String? initialQuery;

  const EnhancedSearchBar({
    super.key,
    required this.onSearch,
    required this.onProductTap,
    this.initialQuery,
  });

  @override
  State<EnhancedSearchBar> createState() => _EnhancedSearchBarState();
}

class _EnhancedSearchBarState extends State<EnhancedSearchBar>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final SearchService _searchService = SearchService();

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  List<ProductModel> _searchResults = [];
  List<String> _suggestions = [];
  List<ProductModel> _popularProducts = [];
  bool _isSearching = false;
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: UIConstants.animationNormal,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: UIConstants.curveEaseOut,
    ));

    if (widget.initialQuery != null) {
      _searchController.text = widget.initialQuery!;
    }

    _loadPopularProducts();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    _focusNode.dispose();
    _searchService.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _showSuggestions = _focusNode.hasFocus && _searchController.text.isEmpty;
    });
    if (_showSuggestions) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  void _loadPopularProducts() async {
    final products = await _searchService.getPopularProducts();
    setState(() {
      _popularProducts = products;
    });
  }

  void _onSearchChanged(String query) async {
    setState(() {
      _isSearching = query.isNotEmpty;
      _showSuggestions = _focusNode.hasFocus && query.isEmpty;
    });

    if (query.isEmpty) {
      _searchResults.clear();
      _suggestions.clear();
      return;
    }

    // Obtener sugerencias
    final suggestions = await _searchService.getSearchSuggestions(query);
    setState(() {
      _suggestions = suggestions;
    });

    // Búsqueda en tiempo real
    _searchService.searchWithDebounce(query).listen((results) {
      if (mounted) {
        setState(() {
          _searchResults = results;
          _isSearching = false;
        });
      }
    });
  }

  void _onSearchSubmitted(String query) {
    widget.onSearch(query);
    _focusNode.unfocus();
    setState(() {
      _showSuggestions = false;
    });
  }

  void _onSuggestionTap(String suggestion) {
    _searchController.text = suggestion;
    widget.onSearch(suggestion);
    _focusNode.unfocus();
  }

  void _onProductTap(ProductModel product) {
    widget.onProductTap(product);
    _focusNode.unfocus();
    setState(() {
      _showSuggestions = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;

    return Column(
      children: [
        _buildSearchField(context, isDark, screenWidth),
        if (_showSuggestions) _buildSuggestionsPanel(context, isDark),
      ],
    );
  }

  Widget _buildSearchField(
      BuildContext context, bool isDark, double screenWidth) {
    return Container(
      padding: EdgeInsets.all(_getSearchPadding(screenWidth)),
      decoration: BoxDecoration(
        color: isDark ? UIConstants.cardBgDark : UIConstants.white,
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _focusNode,
        style: TextStyle(
          color: isDark ? UIConstants.textWhite : UIConstants.textPrimary,
          fontSize: _getSearchFontSize(screenWidth),
        ),
        decoration: InputDecoration(
          hintText: 'Buscar productos, marcas, categorías...',
          hintStyle: TextStyle(
            color: isDark ? Colors.white60 : UIConstants.textSecondary,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: isDark ? UIConstants.textLight : UIConstants.gray,
            size: _getSearchIconSize(screenWidth),
          ),
          suffixIcon: _buildSuffixIcon(context, isDark, screenWidth),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(UIConstants.radiusLG),
            borderSide: BorderSide(
              color: isDark ? UIConstants.grayDark : UIConstants.grayMedium,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(UIConstants.radiusLG),
            borderSide: BorderSide(
              color: isDark ? UIConstants.grayDark : UIConstants.grayMedium,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(UIConstants.radiusLG),
            borderSide: const BorderSide(
              color: UIConstants.primaryBlue,
              width: 2,
            ),
          ),
          filled: true,
          fillColor:
              isDark ? UIConstants.backgroundDark : UIConstants.grayLight,
          contentPadding: EdgeInsets.symmetric(
            horizontal: _getSearchPadding(screenWidth),
            vertical: _getSearchVerticalPadding(screenWidth),
          ),
        ),
        onChanged: _onSearchChanged,
        onSubmitted: _onSearchSubmitted,
      ),
    );
  }

  Widget _buildSuffixIcon(
      BuildContext context, bool isDark, double screenWidth) {
    if (_isSearching) {
      return Padding(
        padding: EdgeInsets.all(_getSearchPadding(screenWidth)),
        child: SizedBox(
          width: _getSearchIconSize(screenWidth),
          height: _getSearchIconSize(screenWidth),
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor:
                const AlwaysStoppedAnimation<Color>(UIConstants.primaryBlue),
          ),
        ),
      );
    }

    if (_searchController.text.isNotEmpty) {
      return IconButton(
        onPressed: () {
          _searchController.clear();
          setState(() {
            _searchResults.clear();
            _suggestions.clear();
          });
        },
        icon: Icon(
          Icons.clear,
          color: isDark ? UIConstants.textLight : UIConstants.gray,
          size: _getSearchIconSize(screenWidth),
        ),
      );
    }

    return IconButton(
      onPressed: () {
        // Activar búsqueda por voz (placeholder)
        _showVoiceSearchDialog(context);
      },
      icon: Icon(
        Icons.mic,
        color: isDark ? UIConstants.textLight : UIConstants.gray,
        size: _getSearchIconSize(screenWidth),
      ),
    );
  }

  Widget _buildSuggestionsPanel(BuildContext context, bool isDark) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            margin: EdgeInsets.only(
              left: _getSearchPadding(MediaQuery.of(context).size.width),
              right: _getSearchPadding(MediaQuery.of(context).size.width),
            ),
            decoration: BoxDecoration(
              color: isDark ? UIConstants.cardBgDark : UIConstants.white,
              borderRadius: BorderRadius.circular(UIConstants.radiusLG),
              boxShadow: [
                BoxShadow(
                  color: isDark ? Colors.black26 : Colors.grey.withOpacity(0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_popularProducts.isNotEmpty) ...[
                  _buildSectionHeader('Productos Populares', isDark),
                  _buildPopularProductsList(context, isDark),
                ],
                if (_suggestions.isNotEmpty) ...[
                  _buildSectionHeader('Sugerencias', isDark),
                  _buildSuggestionsList(context, isDark),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(UIConstants.spacingMD),
      child: Text(
        title,
        style: TextStyle(
          fontSize: UIConstants.fontSizeSM,
          fontWeight: UIConstants.fontWeightBold,
          color: isDark ? UIConstants.textWhite : UIConstants.textPrimary,
        ),
      ),
    );
  }

  Widget _buildPopularProductsList(BuildContext context, bool isDark) {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: UIConstants.spacingMD),
        itemCount: _popularProducts.length,
        itemBuilder: (context, index) {
          final product = _popularProducts[index];
          return Container(
            width: 100,
            margin: const EdgeInsets.only(right: UIConstants.spacingSM),
            child: GestureDetector(
              onTap: () => _onProductTap(product),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(UIConstants.radiusSM),
                    child: product.primaryImage.isNotEmpty
                        ? Image.network(
                            product.primaryImage,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                _buildPlaceholderImage(isDark),
                          )
                        : _buildPlaceholderImage(isDark),
                  ),
                  const SizedBox(height: UIConstants.spacingXS),
                  Text(
                    product.name,
                    style: TextStyle(
                      fontSize: UIConstants.fontSizeXS,
                      color: isDark
                          ? UIConstants.textWhite
                          : UIConstants.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSuggestionsList(BuildContext context, bool isDark) {
    return Column(
      children: _suggestions.map((suggestion) {
        return ListTile(
          leading: Icon(
            Icons.search,
            size: UIConstants.iconSizeSM,
            color: isDark ? UIConstants.textLight : UIConstants.gray,
          ),
          title: Text(
            suggestion,
            style: TextStyle(
              color: isDark ? UIConstants.textWhite : UIConstants.textPrimary,
              fontSize: UIConstants.fontSizeSM,
            ),
          ),
          onTap: () => _onSuggestionTap(suggestion),
          dense: true,
        );
      }).toList(),
    );
  }

  Widget _buildPlaceholderImage(bool isDark) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: isDark ? UIConstants.grayDark : UIConstants.grayLight,
        borderRadius: BorderRadius.circular(UIConstants.radiusSM),
      ),
      child: Icon(
        Icons.image_outlined,
        color: isDark ? UIConstants.textLight : UIConstants.gray,
        size: UIConstants.iconSizeLG,
      ),
    );
  }

  void _showVoiceSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Búsqueda por Voz'),
        content:
            const Text('Esta funcionalidad estará disponible próximamente.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  // Helper methods para responsive design
  double _getSearchPadding(double screenWidth) {
    if (screenWidth < UIConstants.breakpointMobile) {
      return UIConstants.spacingSM;
    } else {
      return UIConstants.spacingMD;
    }
  }

  double _getSearchFontSize(double screenWidth) {
    if (screenWidth < UIConstants.breakpointMobile) {
      return UIConstants.fontSizeSM;
    } else {
      return UIConstants.fontSizeMD;
    }
  }

  double _getSearchIconSize(double screenWidth) {
    if (screenWidth < UIConstants.breakpointMobile) {
      return UIConstants.iconSizeSM;
    } else {
      return UIConstants.iconSizeMD;
    }
  }

  double _getSearchVerticalPadding(double screenWidth) {
    if (screenWidth < UIConstants.breakpointMobile) {
      return UIConstants.spacingSM;
    } else {
      return UIConstants.spacingMD;
    }
  }
}
