import { ChangeDetectionStrategy, Component, input, output } from '@angular/core';
import { takeUntilDestroyed } from '@angular/core/rxjs-interop';
import { FormControl, FormGroup, ReactiveFormsModule } from '@angular/forms';
import { debounceTime, distinctUntilChanged, map } from 'rxjs';

import type { OrdersFilter, User } from '../order.models';

const DEBOUNCE = 400;

@Component({
  selector: 'app-orders-filter',
  imports: [ReactiveFormsModule],
  templateUrl: './orders-filter.component.html',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class OrdersFilterComponent {
  readonly users = input.required<User[]>();

  readonly filterChange = output<OrdersFilter>();

  protected readonly form = new FormGroup({
    userId: new FormControl<number | null>(null),
    minTotal: new FormControl<number | null>(null),
  });

  constructor() {
    this.form.valueChanges
      .pipe(
        debounceTime(DEBOUNCE),
        map((): OrdersFilter => this.form.getRawValue()),
        distinctUntilChanged((a, b) => a.userId === b.userId && a.minTotal === b.minTotal),
        takeUntilDestroyed(),
      )
      .subscribe((filter) => this.filterChange.emit(filter));
  }

  protected clear(): void {
    this.form.reset();
  }
}
