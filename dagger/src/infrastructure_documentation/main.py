import random

from typing import Annotated

import dagger
from dagger import Doc, DefaultPath, dag, function, object_type


@object_type
class InfrastructureDocumentation:
    @function
    async def publish(self, source: dagger.Directory) -> str:
        """Publish the application container after building and testing it on-the-fly"""
        
        image = await self.dockerbuild(source)
        ete_result = await self.ete_testing(image)
        
        return await image.publish(
            f"infrastructure-documentation-{random.randrange(10**8)}"
        )
    
    # using a Dockerfile to build and return a container
    @function
    def build(
        self,
        src: Annotated[
            dagger.Directory,
            DefaultPath("./")
        ],
    ) -> dagger.Container:
        """Build and image from existing Dockerfile"""
        self.unittesting(src)
        ref = src.docker_build()
        return (
            ref
        )
    
    # @function
    # def dev(self, source: Annotated[dagger.Directory, DefaultPath("./")]) -> dagger.Container:
    #     """Return the result of running unit tests"""
    #     # directory = dagger.Directory("./")
    #     return (
    #         # self.install_dep(source)
    #         dag.container()
    #         .from_("squidfunk/mkdocs-material")
    #         .with_mounted_directory("/docs", source)
    #         # .with_mounted_cache("/root/.npm", node_cache)
    #         .with_workdir("/docs")
    #         .with_exec(["pip", "install", "Pygments", "pymdown-extensions", "mkdocs-git-revision-date-localized-plugin"])
    #         # .with_exec(["mkdocs", "serve", "-a", "0.0.0.0:8000"])
    #         .with_exposed_port(8000)
    #         .as_service(args=["mkdocs", "serve", "-a", "0.0.0.0:8000"])
    #         # .stdout()
    #     )


    # @function
    # async def runsemver(
    #     self,
    #     src: Annotated[
    #         dagger.Directory,
    #         DefaultPath("./")
    #     ],
    #     releaserc: Annotated[
    #         dagger.File,
    #         DefaultPath("./.releaserc")
    #     ],
    # ) -> dagger.Container:
    #     """Run Semver """
    #     build = await (
    #         self.buildsemver(src)
    #     )
    #     return await(
    #         build
    #         .with_file("/app/.releaserc", releaserc)
    #         .with_exec(["npx", "semantic-release"])
    #     )

    # @function
    # async def buildsemver(
    #     self,
    #     src: Annotated[
    #         dagger.Directory,
    #         DefaultPath("./")
    #     ],
    # ) -> dagger.Container:
    #     """Build a semver container"""
    #     node_cache = dag.cache_volume("node")
    #     return await(
    #         dag.container()
    #         .from_("node:alpine3.21")
    #         .with_directory("/app", src)
    #         .with_workdir("/app")
    #         .with_exec(["apk", "add", "--no-cache", "git", "openssh"])
    #         .with_exec(["npm", "init", "-y"])
    #         .with_exec(["npm", "install", "--save-dev", "semantic-release", "@semantic-release/exec"])
    #         .with_exec(["npm", "audit", "signatures"])
    #         .with_exec(["ls", "-la"])
    #         # .with_exec(["npx", "semantic-release"])
    #         )
    
    # perform unit testing
    @function
    def unittesting(self,     
            source: Annotated[
            dagger.Directory,
            DefaultPath("./")
        ]) -> str:
        """Return the result of running unit tests"""
        return (
            self.installdependencies(source)
            .with_exec(["mkdocs", "get-deps"])
        )
    
    # install dependencies for the application
    @function
    def installdependencies(self, source: dagger.Directory) -> dagger.Container:
        """Build a ready-to-use development environment"""
        node_cache = dag.cache_volume("node")
        return (
            dag.container()
            .from_("squidfunk/mkdocs-material")
            .with_directory("/docs", source)
            # .with_mounted_cache("/root/.npm", node_cache)
            .with_workdir("/docs")
            .with_exec(["pip", "install", "Pygments", "pymdown-extensions", "mkdocs-git-revision-date-localized-plugin"])
        )