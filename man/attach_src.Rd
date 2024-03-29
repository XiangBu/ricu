% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/setup-attach.R
\name{attach_src}
\alias{attach_src}
\alias{attach_src.src_cfg}
\alias{attach_src.character}
\alias{setup_src_env}
\alias{setup_src_env.src_cfg}
\alias{new_src_tbl}
\alias{as_src_tbl}
\alias{new_src_env}
\alias{as_src_env}
\title{Data attach utilities}
\usage{
attach_src(x, ...)

\method{attach_src}{src_cfg}(x, assign_env = NULL, data_dir = src_data_dir(x), ...)

\method{attach_src}{character}(x, assign_env = NULL, data_dir = src_data_dir(x), ...)

setup_src_env(x, env, ...)

\method{setup_src_env}{src_cfg}(x, env, data_dir = src_data_dir(x), ...)

new_src_tbl(files, col_cfg, tbl_cfg, prefix, src_env)

as_src_tbl(x, ...)

new_src_env(x, env = new.env(parent = data_env()))

as_src_env(x)
}
\arguments{
\item{x}{Data source to attach}

\item{...}{Forwarded to further calls to \code{attach_src()}}

\item{assign_env}{Environment in which the data source will become available}

\item{data_dir}{Directory used to look for \code{\link[fst:fst]{fst::fst()}} files; \code{NULL} calls
\code{\link[=data_dir]{data_dir()}} using the source name as \code{subdir} argument}

\item{env}{Environment where data proxy objects are created}

\item{files}{File names of \code{fst} files that will be used to create a \code{prt}
object (see also \code{\link[prt:new_prt]{prt::new_prt()}})}

\item{col_cfg}{Coerced to \code{col_cfg} by calling \code{\link[=as_col_cfg]{as_col_cfg()}}}

\item{tbl_cfg}{Coerced to \code{tbl_cfg} by calling \code{\link[=as_tbl_cfg]{as_tbl_cfg()}}}

\item{prefix}{Character vector valued data source name(s) (used as class
prefix)}

\item{src_env}{The data source environment (as \code{src_env} object)}
}
\value{
The constructors \code{new_src_env()}/\code{new_src_tbl()} as well as coercion
functions \code{as_src_env()}/\code{as_src_tbl()} return \code{src_env} and \code{src_tbl}
objects respectively. The function \code{attach_src()} is called for side
effects and returns \code{NULL} invisibly, while \code{setup_src_env()} instantiates
and returns a \code{src_env} object.
}
\description{
Making a dataset available to \code{ricu} consists of 3 steps: downloading
(\code{\link[=download_src]{download_src()}}), importing (\code{\link[=import_src]{import_src()}}) and attaching
(\code{\link[=attach_src]{attach_src()}}). While downloading and importing are one-time procedures,
attaching of the dataset is repeated every time the package is loaded.
Briefly, downloading loads the raw dataset from the internet (most likely
in \code{.csv} format), importing consists of some preprocessing to make the
data available more efficiently and attaching sets up the data for use by
the package.
}
\details{
Attaching a dataset sets up two types of S3 classes: a single \code{src_env}
object, containing as many \code{src_tbl} objects as tables are associated with
the dataset. A \code{src_env} is an environment with an \code{id_cfg} attribute, as
well as sub-classes as specified by the data source \code{class_prefix}
configuration setting (see \code{\link[=load_src_cfg]{load_src_cfg()}}). All \code{src_env} objects created
by calling \code{attach_src()} represent environments that are direct
descendants of the \code{data} environment and are bound to the respective
dataset name within that environment. While \code{attach_src()} does not
immediately instantiate a \code{src_env} object, it rather creates a promise
using \code{\link[base:delayedAssign]{base::delayedAssign()}} which evaluates to a \code{src_env} upon first
access. This allows for data sources to be set up where the data is missing
in a way that prompts the user to download and import the data when first
accessed.

Additionally, \code{attach_src()} creates an active binding using
\code{\link[base:bindenv]{base::makeActiveBinding()}}, binding a function to the dataset name within
the environment passed as \code{assign_env}, which retrieves the respective
\code{src_env} from the \code{data} environment. This shortcut is set up for
convenience, such that for example the MIMIC-III demo dataset not only is
available as \verb{ricu::data::mimic_demo}, but also as \code{ricu::mimic_demo} (or if
the package namespace is attached, simply as \code{mimic_demo}). The \code{ricu}
namespace contains objects \code{mimic}, \code{mimic_demo}, \code{eicu}, etc. which are
used as such links when loading the package. However, new data sets can be
set up an accessed in the same way.

If set up correctly, it is not necessary for the user to directly call
\code{attach_src()}. When the package is loaded, the default data sources are
attached automatically. This default can be controlled by setting as
environment variable \code{RICU_SRC_LOAD} a comma separated list of data source
names before loading the library. Setting this environment variable as\preformatted{Sys.setenv(RICU_SRC_LOAD = "mimic_demo,eciu_demo")
}

will change the default of loading both MIMIC-III and eICU, alongside the
respective demo datasets, and HiRID, to just the two demo datasets. For
setting an environment variable upon startup of the R session, refer to
\code{\link[base:Startup]{base::.First.sys()}}.

The \code{src_env} promise for each data source is created using the S3 generic
function \code{setup_src_env()}. This function checks if all required files are
available from \code{data_dir}. If files are missing the user is prompted for
download in interactive sessions and an error is thrown otherwise. As soon
as all required data is available, a \code{src_tbl} object is created per table
and assigned to the \code{src_env}.

The S3 class \code{src_tbl} inherits from \code{\link[prt:new_prt]{prt}}, which
represents a partitioned \code{\link[fst:fst]{fst}} file. In addition to the \code{prt}
object, meta data in the form of \code{col_cfg} and \code{tbl_cfg} is associated with
a \code{src_tbl} object (see \code{\link[=load_src_cfg]{load_src_cfg()}}). Furthermore, as with \code{src_env},
sub-classes are added as specified by the source configuration
\code{class_prefix} entry. This allows certain functionality, for example data
loading, to be adapted to data source-specific requirements.
}
\examples{
\dontrun{

Sys.setenv(RICU_SRC_LOAD = "")
library(ricu)

ls(envir = data)
exists("mimic_demo")

attach_src("mimic_demo")

ls(envir = data)
exists("mimic_demo")

mimic_demo

}

}
