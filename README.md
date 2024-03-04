# pendata

Pension data for the Reason-Rockefeller pension policy analysis tool.

You can install the **development** version from
[Github](https://github.com/donboyd5/pendata)

```s
# install.packages("remotes")
remotes::install_github("donboyd5/pendata")
```

In the near term, this package will contain two kinds of pension-related data:

- **Commonly used actuarial tables** from standardized sources that may be useful for modeling many different pension systems. These data sources will be in a consistent format, easing their use in modeling. For example, the first iteration will include the Society of Actuaries' (SOA) MP-2018 mortality improvement scale.

- **System-specific data**. For example, the first iteration will include mortality, other separation tables, and constants specific to the Florida Retirement System (FRS). Later versions of this package will include data from other plans. This package will take raw data for an individual pension system, in formats that will vary from system to system, and convert the data to a format that is consistent from system to system. For example, mortality tables will follow a common format and will be consistent with the format used for SOA tables.

In addition, the package includes tools to convert data from the package's formats to selected other formats.


