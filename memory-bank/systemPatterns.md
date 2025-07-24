# System Patterns: DscConfig.AADConnect Architecture

## Architecture Overview

DscConfig.AADConnect implements a composite resource pattern that serves as an
abstraction layer between configuration management systems and the underlying
AADConnectDsc resources. It follows DSC Community patterns for composite
resources while providing specialized functionality for bulk configuration
processing.

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                Configuration Management Layer                   │
│              (AADConnectConfig, Datum, DscWorkshop)            │
└─────────────────────────┬───────────────────────────────────────┘
                          │ Configuration Data Arrays
                          ▼
┌─────────────────────────────────────────────────────────────────┐
│                    DscConfig.AADConnect                        │
│  ┌─────────────────┐                  ┌─────────────────────┐  │
│  │   AADSyncRules  │                  │ AADConnectDirectory │  │
│  │   Composite     │                  │ ExtensionAttributes │  │
│  │   Resource      │                  │ Composite Resource  │  │
│  └─────────────────┘                  └─────────────────────┘  │
└─────────────────────────┬───────────────────────────────────────┘
                          │ Individual Resource Instances
                          ▼
┌─────────────────────────────────────────────────────────────────┐
│                      AADConnectDsc                              │
│  ┌─────────────────┐                  ┌─────────────────────┐  │
│  │   AADSyncRule   │                  │ AADConnectDirectory │  │
│  │   DSC Resource  │                  │ ExtensionAttribute  │  │
│  │                 │                  │ DSC Resource        │  │
│  └─────────────────┘                  └─────────────────────┘  │
└─────────────────────────┬───────────────────────────────────────┘
                          │ ADSync PowerShell Module
                          ▼
┌─────────────────────────────────────────────────────────────────┐
│                   Azure AD Connect Service                     │
│            (Synchronization Engine & Database)                 │
└─────────────────────────────────────────────────────────────────┘
```

## Component Architecture

### Composite Resource Design

#### AADSyncRules Composite Resource

**Purpose**: Processes arrays of sync rule configurations and generates 
individual AADSyncRule DSC resource instances.

**Responsibilities**:
- Accept hashtable arrays representing sync rule configurations
- Validate required properties for each sync rule
- Generate unique execution names from connector and rule names
- Apply default values (e.g., Ensure = 'Present')
- Handle expression validation for attribute flow mappings
- Create individual AADSyncRule resource calls

**Input Structure**:
```powershell
$Items = @(
    @{
        Name = 'Custom Rule 1'
        ConnectorName = 'contoso.com'
        Direction = 'Inbound'
        # ... additional properties
    },
    @{
        Name = 'Custom Rule 2' 
        ConnectorName = 'fabrikam.com'
        Direction = 'Outbound'
        # ... additional properties
    }
)
```

#### AADConnectDirectoryExtensionAttributes Composite Resource

**Purpose**: Processes arrays of directory extension attribute configurations
and generates individual AADConnectDirectoryExtensionAttribute DSC resource 
instances.

**Responsibilities**:
- Accept hashtable arrays representing directory extension configurations
- Validate directory extension properties
- Generate unique execution names from attribute name and object class
- Apply default values for optional properties
- Create individual AADConnectDirectoryExtensionAttribute resource calls

### Data Flow Patterns

#### Configuration Processing Flow

```
Configuration Data (Arrays)
          │
          ▼
    Composite Resource
          │
          ├─── Iterate Array Items
          │    ├─── Validate Required Properties
          │    ├─── Apply Default Values
          │    └─── Generate Execution Name
          │
          ├─── Create Resource Instances
          │    ├─── Use Get-DscSplattedResource
          │    ├─── Set Execution Name
          │    └─── Pass Properties
          │
          └─── Invoke Resource Creation
               └─── Delegate to AADConnectDsc Resources
```

#### Execution Name Generation

Both composite resources use a standardized pattern for generating execution 
names to prevent conflicts:

**AADSyncRules Pattern**:
```powershell
$executionName = ($item.ConnectorName + '__' + $item.Name) -replace '[\s(){}/\\:-]', '_'
```

**AADConnectDirectoryExtensionAttributes Pattern**:
```powershell
$executionName = ($item.Name + '__' + $item.AssignedObjectClass) -replace '[\s(){}/\\:-]', '_'
```

### Integration Patterns

#### Configuration Management Integration

**Pattern**: Data-Driven Resource Generation
- Accepts standardized hashtable arrays from configuration systems
- Provides predictable interfaces for bulk resource management
- Integrates with Datum hierarchical data merging
- Supports DscWorkshop configuration patterns

#### DSC Framework Integration

**Pattern**: Composite Resource Delegation
- Implements DSC configuration keywords (not class-based resources)
- Uses Get-DscSplattedResource for proper resource instantiation
- Delegates actual functionality to underlying AADConnectDsc resources
- Maintains DSC compilation and validation compatibility

#### Error Handling Strategy

**Pattern**: Early Validation and Graceful Delegation
1. **Input Validation**: Validate array structure and required properties
2. **Default Application**: Apply sensible defaults for missing optional properties
3. **Name Generation**: Create safe execution names with collision avoidance
4. **Resource Delegation**: Pass validated data to underlying DSC resources
5. **Error Propagation**: Allow underlying resources to handle detailed validation

## Key Design Decisions

### Composite Resource vs Class-Based Resources

**Decision**: Use configuration-keyword composite resources instead of class-based resources

**Rationale**:
- Simpler to implement for array processing scenarios
- Better integration with configuration management systems
- Easier to maintain and extend
- Consistent with DscWorkshop patterns
- Reduced complexity compared to class-based resource implementation

### Execution Name Strategy

**Decision**: Generate execution names from configuration data properties

**Rationale**:
- Prevents resource name collisions in bulk scenarios
- Creates predictable, meaningful resource names
- Enables easier troubleshooting and identification
- Maintains consistency across different configuration scenarios

### Default Value Application

**Decision**: Apply 'Present' as default for Ensure property when not specified

**Rationale**:
- Most common use case is resource creation/management
- Reduces configuration data verbosity
- Consistent with DSC community patterns
- Provides safe defaults for typical scenarios

### Validation Strategy

**Decision**: Minimal validation in composite resources, delegate to underlying resources

**Rationale**:
- Avoids duplication of validation logic
- Ensures consistency with AADConnectDsc validation
- Simplifies maintenance when underlying resources change
- Maintains clear separation of concerns

## Testing and Validation Patterns

### Unit Testing Strategy

**Focus Areas**:
- Array iteration and processing logic
- Execution name generation algorithms
- Default value application
- Resource instantiation parameters

**Mock Strategies**:
- Mock Get-DscSplattedResource calls
- Validate parameter passing to underlying resources
- Test edge cases in configuration data

### Integration Testing

**Test Scenarios**:
- End-to-end configuration processing
- Integration with actual AADConnectDsc resources
- Configuration data validation
- Error handling and propagation

This architecture provides a clean abstraction layer that simplifies the use of
AADConnectDsc resources while maintaining full compatibility with DSC
frameworks and configuration management systems.
