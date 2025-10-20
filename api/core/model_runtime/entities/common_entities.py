from pydantic import BaseModel, model_validator


class I18nObject(BaseModel):
    """
    Model class for i18n object.
    """

    zh_Hans: str | None = None
    en_US: str
    ru_RU: str | None = None

    @model_validator(mode="after")
    def _(self):
        if not self.zh_Hans:
            self.zh_Hans = self.en_US
        if not self.ru_RU:
            self.ru_RU = self.en_US
        return self
