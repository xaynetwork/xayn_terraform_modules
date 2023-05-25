from abc import abstractmethod


class InfraRepository():

    @abstractmethod
    def notify_stack_deployment(self):
        pass


class BotoInfraRepository(InfraRepository):

    def notify_stack_deployment(self):
        pass
