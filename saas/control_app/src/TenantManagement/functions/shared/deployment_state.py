from strenum import StrEnum


class DeploymentState(StrEnum):
    NEEDS_UPDATE = "NEEDS_UPDATE"
    UPDATED_IN_PROGRESS = "UPDATED_IN_PROGRESS"
    DEPLOYED = "DEPLOYED"
    NEEDS_DELETION = "NEEDS_DELETION"
    DELETION_IN_PROGRESS = "DELETION_IN_PROGRESS"
    DELETED = "DELETED"
    UPDATE_FAILED = "UPDATE_FAILED"
    DELETION_FAILED = "DELETION_FAILED"
