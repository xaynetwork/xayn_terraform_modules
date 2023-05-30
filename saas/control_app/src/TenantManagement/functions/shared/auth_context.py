class AuthContext:
    _method_arns: list[str]
    _is_authorized: bool

    def __init__(self, method_arns: list[str], is_authorized: bool) -> None:
        self._is_authorized = is_authorized
        self._method_arns = method_arns

    @property
    def is_authorized(self) -> bool:
        return self._is_authorized

    @property
    def method_arns(self) -> list[str]:
        return self._method_arns


class AuthorizedContext(AuthContext):
    _plan_key: str

    def __init__(self, plan_key: str, method_arns: list[str]) -> None:
        self._plan_key = plan_key
        super().__init__(method_arns, True)

    @property
    def plan_key(self):
        return self._plan_key

    @property
    def method_arns(self) -> list[str]:
        return super().method_arns


class UnauthorizedContext(AuthContext):
    def __init__(self, method_arns: list[str]) -> None:
        super().__init__(method_arns, False)
