// Copyright 2021 Solarius Intellectual Properties Ky
// Authors: Ville Sundell
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

address {{sender}} {

/// A dummy tao for testing and development purposes.
/// Can be passed along like....a torch.
module Torch {
    /// This tao does not contain anything, and is
    /// intended to be used only for testing.
    struct Tao has key, store {}

    /// Create a new dummy tao
    public fun new(): Tao {
        Tao {}
    }
    spec fun new {
        aborts_if false;
    }

    /// Destroy a dummy tao created with `new()`
    public fun destroy(tao: Tao) {
        let Tao {} = tao;
    }
    spec fun destroy {
        aborts_if false;
    }
}
}
