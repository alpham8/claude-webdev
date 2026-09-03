## 6) Code Maintainability

### Architecture

- **Thin controllers / routes**: Business logic belongs in services or use-cases.
- **DTOs / ViewModels** at I/O boundaries: Never expose persistence entities directly to the outside.
- **Errors are explicit and meaningful**: Never silently swallow exceptions. Log or re-throw with context.
- **Constructor discipline**: Constructors assign dependencies — nothing else. No business logic, no I/O, no HTTP calls. Pure configuration (e.g. setting up a converter) is acceptable.
- **All dependencies required**: Every injected service must be non-optional. If a class needs a dependency, it must always receive one — no fallback behaviour on missing services.
- **Specific exceptions**: Throw domain-specific exceptions (e.g. `PostNotFoundException`), not generic `\RuntimeException` or `\Exception`. Catch specific exceptions, never bare `catch (\Exception $e)` unless re-throwing.

### Symfony/Shopware Service Configuration (PHP over XML)

For **new** service definitions (Symfony DI: registrations, decorators, tags), use the PHP config format (`services.php` with `Symfony\Component\DependencyInjection\Loader\Configurator\ContainerConfigurator`) instead of `services.xml`. PHP config is Symfony's current recommended style — typed, IDE-navigable, refactor-safe — while XML is legacy-but-supported, not actively recommended for new code.

- Applies to **new** service files only. Don't rewrite an existing, working `services.xml` into PHP just for its own sake — that's a refactor unrelated to the task at hand (see Refactoring Rules below).
- If a plugin's bootstrap only knows how to load XML (e.g. a Shopware plugin `build()` method wired to `XmlFileLoader`), adding a first PHP config file requires also wiring a `PhpFileLoader` for it — treat that loader change as part of the same task, not a silent side effect, and call it out explicitly since it changes how the plugin bootstraps *all* its services, not just the new one.
- Where Shopware/Symfony attributes cover the need (`#[AsDecorator]`, `#[Autoconfigure]`, `#[AsMessageHandler]`, etc.), prefer attributes over either config format — least ceremony, co-located with the class.

### Documentation

Comments fall into three categories with **different rules**. Do not apply one category's rule to another.

- Keep comments up to date with the code — stale comments are worse than none.

#### 1. Type and Method Docblocks — Always Write Them

A docblock on a class, interface, trait, enum or method is good style regardless of what the rest of the file does. **Write one even when nothing else in the file is documented.** Never skip a docblock because the surrounding code lacks them — this is the one place where you deliberately do not follow the existing example.

- Explain *why* the method exists and what it is for. A block that only restates the method name earns its place only once it says something the signature does not.
- **Where parameters carry native types** (PHP type declarations, TypeScript annotations, Python hints), the docblock must additionally describe **what each parameter means** — the type is already in the signature, so repeating it adds nothing. State the meaning, the unit, the valid range, or the constraint.
- Document the return value the same way: what the caller gets, including what an empty or zero result signifies.
- **Every type gets a docblock too**: what the class is responsible for, what role it plays, and what a reader has to know before using it.
- **Abstract classes and interfaces have the highest explanation need of all** — they carry signatures and no behaviour, so the code itself shows an implementor nothing. Document the contract: what an implementation must guarantee, which invariants hold, what the method is called with and when, and what a correct implementation is expected to do in the edge cases.
- Where a **parameter or return type is itself an interface or abstract class**, the description must say what the caller may assume or what an implementation is expected to provide. The type name alone does not convey a contract.

```php
// ❌ Bad — the reader learns nothing an implementor actually needs
interface PaymentResolver
{
    public function resolve(string $paymentName): int;
}

// ✅ Good — the contract is documented, because the code cannot show it
/**
 * Resolves a payment method name submitted by the storefront to a stored payment mean id.
 *
 * Implementations are consulted before the id is written to s_user.paymentID. They exist because
 * some providers submit virtual names that match no database row. An implementation that does not
 * recognise a name must return 0 rather than guess — the caller then falls back to the default.
 */
interface PaymentResolver
{
    /**
     * @param string $paymentName Name as submitted by the storefront; may be a provider-internal
     *                            virtual name that exists in no database row.
     * @return int Id of an active payment mean, or 0 when this resolver does not handle the name.
     */
    public function resolve(string $paymentName): int;
}
```

```php
// ❌ Bad — the docblock only repeats what the signature already states
/**
 * Finds the default credit card payment id.
 *
 * @param int $shopId
 * @return int
 */
public function findDefaultCreditCardPaymentId(int $shopId): int

// ✅ Good — the types stay in the signature, the block explains meaning
/**
 * Id of the card brand a customer choosing "Kreditkarte" should be stored with.
 *
 * Mirrors what the payment provider's JavaScript picks in the checkout: the first active card
 * brand of the group. Which brand it is does not restrict the customer — the checkout regroups
 * all active brands back into the single option.
 *
 * @param int $shopId Subshop the payment means are scoped to; card brands may differ per shop.
 * @return int Payment mean id, or 0 when no card brand is active at all.
 */
public function findDefaultCreditCardPaymentId(int $shopId): int
```

#### 2. Unit Tests — No Limit

**In tests, comment as much as it takes to make the test understandable.** There is no density limit here. A test is documentation of the behaviour under test, and a reader who cannot follow the arrange/act/assert steps gains nothing from a terse test. Explain the scenario, the fixture data, and above all *why* a particular expectation is the correct one.

#### 3. Inline Comments — Match the Surrounding File (Non-Negotiable)

This is where generated code goes wrong. **Before adding an inline comment, read the file you are editing and match its existing inline commenting style.**

- **Never write eight lines of inline comment for a one-line change in a file that has no inline comments at all.** This is the single most common failure and it is always wrong.
- If the file carries **no inline comments**, add none. The absence is a deliberate signal about how this codebase is written.
- If the file comments **densely inline**, match that density rather than under-documenting.
- Judge by the file first, then the surrounding directory or module. Do not generalise from an unrelated part of the repository. A **new** file has no history of its own, so its yardstick is the directory it is created in — compare against neighbours of similar size, not against the smallest file there.
- Check the lines **you added**, not the resulting file: the share of inline comments among your added lines should not markedly exceed the share the file already had. Adding an 80-line block at 30 % inline comments to a file sitting at 4 % is the failure this rule exists to prevent.
- The exception is a genuinely non-obvious *why* — a workaround, a subtle ordering constraint, a deliberate deviation from the expected approach. Such a comment is warranted even in a file with no inline comments at all, because the reader cannot recover that reasoning from the code. Keep it to one or two lines.

```php
// ❌ Bad — the rest of the file carries no inline comments; this reads as AI output
public function calculateTotal(array $items): int
{
    // Initialise the running total to zero
    $total = 0;

    // Iterate over every item in the collection
    foreach ($items as $item) {
        // Add the item price to the running total
        $total += $item->price;
    }

    // Return the accumulated total
    return $total;
}

// ✅ Good — docblock yes, inline narration no, because the code already says all of this
/**
 * Sum of the line item prices, in cents.
 *
 * @param OrderItem[] $items Items of a single order; an empty order totals 0.
 * @return int Total in cents, never negative.
 */
public function calculateTotal(array $items): int
{
    $total = 0;

    foreach ($items as $item) {
        $total += $item->price;
    }

    return $total;
}
```


### Refactoring Rules

- Only refactor as part of a focused, clearly scoped change.
- Never mix refactoring with feature work in the same commit/diff.
- Leave the code measurably better than you found it (Boy Scout Rule).