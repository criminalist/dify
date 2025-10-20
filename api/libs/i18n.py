"""
Backend Internationalization (i18n) Module

This module provides translation support for backend messages.
It's designed to be backward compatible and non-breaking.
"""

from typing import Dict, Any, Optional
from configs import dify_config


class BackendI18n:
    """
    Backend internationalization system.
    
    Provides translation support for backend error messages and user-facing strings.
    Falls back to English if translation is not available.
    """
    
    # Translation dictionary
    TRANSLATIONS: Dict[str, Dict[str, str]] = {
        "en-US": {
            # Tool errors
            "tool.credentials_error": "Please check your tool provider credentials",
            "tool.not_found": "there is not a tool named {tool_name}",
            "tool.parameter_error": "tool parameters validation error: {error}, please check your tool parameters",
            "tool.invoke_error": "tool invoke error: {error}",
            "tool.unknown_error": "unknown error: {error}",
            
            # Quota errors
            "quota.exhausted": "Your quota for Dify Hosted Model Provider has been exhausted. Please go to Settings -> Model Provider to complete your own provider credentials.",
            
            # General errors
            "error.internal_server": "Internal Server Error, please contact support.",
            "error.invalid_json": "Invalid JSON payload received or JSON payload is empty.",
            
            # Auth errors
            "auth.incorrect_api_key": "Incorrect API key provided",
            "auth.unauthorized": "Unauthorized access",
            
            # Validation errors
            "validation.required_field": "This field is required",
            "validation.invalid_format": "Invalid format",
        },
        "ru-RU": {
            # Tool errors
            "tool.credentials_error": "Пожалуйста, проверьте учетные данные поставщика инструментов",
            "tool.not_found": "инструмент с именем {tool_name} не найден",
            "tool.parameter_error": "ошибка валидации параметров инструмента: {error}, пожалуйста, проверьте параметры инструмента",
            "tool.invoke_error": "ошибка вызова инструмента: {error}",
            "tool.unknown_error": "неизвестная ошибка: {error}",
            
            # Quota errors
            "quota.exhausted": "Ваша квота для размещенного поставщика моделей Dify исчерпана. Перейдите в Настройки -> Поставщик моделей для настройки собственных учетных данных.",
            
            # General errors
            "error.internal_server": "Внутренняя ошибка сервера, обратитесь в службу поддержки.",
            "error.invalid_json": "Получен неверный JSON или JSON пуст.",
            
            # Auth errors
            "auth.incorrect_api_key": "Предоставлен неверный API ключ",
            "auth.unauthorized": "Неавторизованный доступ",
            
            # Validation errors
            "validation.required_field": "Это поле обязательно",
            "validation.invalid_format": "Неверный формат",
        }
    }
    
    @classmethod
    def get_text(cls, key: str, **kwargs) -> str:
        """
        Get translated text for the given key.
        
        Args:
            key: Translation key
            **kwargs: Format parameters for the translation
            
        Returns:
            Translated text, or the key itself if translation not found
        """
        # Get current language from config, fallback to en-US
        language = getattr(dify_config, 'DEFAULT_LANGUAGE', 'en-US')
        
        # Get translations for current language, fallback to English
        translations = cls.TRANSLATIONS.get(language, cls.TRANSLATIONS['en-US'])
        
        # Get translation, fallback to key if not found
        text = translations.get(key, key)
        
        # Format with parameters if provided
        try:
            return text.format(**kwargs) if kwargs else text
        except (KeyError, ValueError):
            # If formatting fails, return the text as-is
            return text
    
    @classmethod
    def get_available_languages(cls) -> list[str]:
        """Get list of available languages."""
        return list(cls.TRANSLATIONS.keys())
    
    @classmethod
    def is_language_supported(cls, language: str) -> bool:
        """Check if language is supported."""
        return language in cls.TRANSLATIONS


# Convenience function for easy import
def _(key: str, **kwargs) -> str:
    """
    Convenience function for getting translated text.
    
    Usage:
        from libs.i18n import _
        error_message = _("tool.credentials_error")
    """
    return BackendI18n.get_text(key, **kwargs)
